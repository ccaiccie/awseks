#!/usr/bin/env python3
"""Unit 6A address planner. Reads a plan file and prints checks. Creates nothing and calls no network.

  python3 plan.py capacity plan-6b.json
  python3 plan.py overlap  plan-6b.json [EXTRA_CIDR ...]
  python3 plan.py route    plan-6b.json SUBNET DESTINATION [DESTINATION ...]
  python3 plan.py filter   plan-6b.json
"""
import ipaddress
import json
import sys

AWS_RESERVED = 5  # first four and the last address of every subnet


def load(path):
    with open(path, encoding='utf-8') as f:
        return json.load(f)


def net(cidr):
    return ipaddress.ip_network(cidr, strict=True)


def capacity(p):
    n = p['nodes']
    per_node = n['enis'] * n['ipv4_per_eni']
    worst = 'OK'
    print(f"Plan: {p['name']}")
    print(f"Node address footprint: {n['instance_type']} has up to {n['enis']} ENIs x {n['ipv4_per_eni']} IPv4 addresses = {per_node} per node")
    for name, s in p['subnets'].items():
        cidr = net(s['cidr'])
        usable = cidr.num_addresses - AWS_RESERVED
        rows = []
        if name.startswith('private'):
            count = n['max_nodes_per_az'] + n['upgrade_surge_per_az']
            rows.append((f"nodes: {n['max_nodes_per_az']} + {n['upgrade_surge_per_az']} extra during a node update, x {per_node}", count * per_node))
            rows += [tuple(r) for r in p['consumers_per_private_subnet']]
        else:
            rows += [tuple(r) for r in p['consumers_per_public_subnet']]
        total = sum(v for _, v in rows)
        pct = 100.0 * total / usable
        limit = p['max_planned_percent']
        verdict = 'OK' if pct <= limit else ('TIGHT' if total <= usable else 'FAIL')
        if verdict == 'FAIL' or (verdict == 'TIGHT' and worst == 'OK'):
            worst = verdict
        print()
        print(f"{name}  {cidr}  AZ {s['az']}  ({s['role']})")
        print(f"  {cidr.num_addresses} addresses - {AWS_RESERVED} reserved by AWS = {usable} usable")
        for label, v in rows:
            print(f"  {v:5d}  {label}")
        print(f"  {total:5d}  planned = {pct:.1f}% of usable -> {verdict}")
    print()
    print(f"Rule used: OK if planned <= {p['max_planned_percent']}% of usable, TIGHT if it fits with less headroom, FAIL if it does not fit.")
    print(f"RESULT {worst}")
    return 0 if worst != 'FAIL' else 1


def overlap(p, extra):
    vpc = net(p['vpc_cidr'])
    svc = net(p['service_cidr'])
    problems = 0
    print(f"VPC CIDR {vpc}   Service CIDR {svc}")
    private = [net('10.0.0.0/8'), net('172.16.0.0/12'), net('192.168.0.0/16')]
    if not any(svc.subnet_of(r) for r in private):
        print('  PROBLEM Service CIDR must be inside 10.0.0.0/8, 172.16.0.0/12 or 192.168.0.0/16'); problems += 1
    if not 12 <= svc.prefixlen <= 24:
        print('  PROBLEM Service CIDR must be between /12 and /24'); problems += 1
    if svc.overlaps(vpc):
        print('  PROBLEM Service CIDR overlaps the VPC CIDR'); problems += 1
    else:
        print('  ok      Service CIDR does not overlap the VPC (it never appears in a VPC route table)')
    subs = {k: net(v['cidr']) for k, v in p['subnets'].items()}
    for k, s in subs.items():
        if not s.subnet_of(vpc):
            print(f'  PROBLEM subnet {k} {s} is outside the VPC'); problems += 1
    keys = list(subs)
    for i, a in enumerate(keys):
        for b in keys[i + 1:]:
            if subs[a].overlaps(subs[b]):
                print(f'  PROBLEM subnets {a} and {b} overlap'); problems += 1
    if problems == 0:
        print(f'  ok      {len(subs)} subnets checked: all inside the VPC, none overlapping')
    for c in extra:
        e = net(c)
        hits = [n for n, x in (('VPC', vpc), ('Service CIDR', svc)) if e.overlaps(x)]
        if hits:
            print(f"  PROBLEM {e} overlaps the {' and the '.join(hits)}: a network you connect later (VPN, peering, office) must not reuse these addresses"); problems += 1
        else:
            print(f'  ok      {e} does not overlap the VPC or the Service CIDR')
    print('RESULT ' + ('OK' if problems == 0 else f'{problems} PROBLEM(S)'))
    return 0 if problems == 0 else 1


def route(p, subnet, dests):
    rt_name = p['subnets'][subnet]['route_table']
    table = p['route_tables'][rt_name]
    svc = net(p['service_cidr'])
    print(f"Route table {rt_name} (used by {subnet}):")
    for prefix, target in table:
        print(f"  {prefix:<16} -> {target}")
    for d in dests:
        ip = ipaddress.ip_address(d)
        matches = [(net(pfx), tgt) for pfx, tgt in table if ip in net(pfx)]
        print()
        print(f"Destination {ip}")
        if not matches:
            print('  no route matches: the packet is dropped')
            continue
        for n, tgt in matches:
            print(f"  matches {str(n):<16} (/{n.prefixlen}) -> {tgt}")
        best = max(matches, key=lambda m: m[0].prefixlen)
        print(f"  WINNER  {best[0]} -> {best[1]}  (longest prefix: the most specific route wins)")
        if ip in svc:
            print(f"  NOTE    {ip} is in the Service CIDR {svc}. No VPC route owns it, so it only matched the default route.")
            print('          A ClusterIP works on a node, where kube-proxy rewrites it to a Pod address before routing (Unit 9).')
            print('          Adding a VPC route for the Service CIDR would not help: no gateway or network interface owns those addresses.')
    return 0


def match(rule, proto, port, peer):
    lo, hi = rule['ports']
    return rule['proto'] in ('all', proto) and lo <= port <= hi and ipaddress.ip_address(peer) in net(rule['cidr'])


def nacl_decision(rules, proto, port, peer):
    for r in sorted(rules, key=lambda r: r['n']):
        if match(r, proto, port, peer):
            return f"rule {r['n']} {r['action'].upper()}", r['action'] == 'allow'
    return 'no numbered rule matched; rule * DENY', False


def filt(p):
    f = p['filter_demo']
    node, server = f['node'], f['server']
    print(f"Request: {node['ip']}:{node['port']} -> {server['ip']}:{server['port']} (tcp, HTTPS out through the NAT gateway)")
    print('  security group outbound (stateful): ' + ('ALLOW, connection is tracked' if any(match(r, 'tcp', server['port'], server['ip']) for r in f['sg_outbound']) else 'DENY'))
    for name, nacl in f['nacls'].items():
        txt, _ = nacl_decision(nacl['outbound'], 'tcp', server['port'], server['ip'])
        print(f"  network ACL '{name}' outbound (stateless): {txt}")
    print()
    print(f"Reply:   {server['ip']}:{server['port']} -> {node['ip']}:{node['port']} (destination port is the node's temporary port)")
    print('  security group (stateful): ALLOW, it is the reply to a tracked connection; no inbound rule is needed')
    for name, nacl in f['nacls'].items():
        txt, ok = nacl_decision(nacl['inbound'], 'tcp', node['port'], server['ip'])
        print(f"  network ACL '{name}' inbound (stateless): {txt}")
        if not ok:
            print(f"    -> the reply is dropped. A network ACL checks every packet on its own, so it must allow the return")
            print(f"       traffic explicitly, for example inbound tcp 1024-65535 from the servers you call.")
    return 0


def main(argv):
    if len(argv) < 3 or argv[1] not in ('capacity', 'overlap', 'route', 'filter'):
        print(__doc__.strip())
        return 2
    p = load(argv[2])
    if argv[1] == 'capacity':
        return capacity(p)
    if argv[1] == 'overlap':
        return overlap(p, argv[3:])
    if argv[1] == 'route':
        if len(argv) < 5:
            print('usage: plan.py route PLAN.json SUBNET DESTINATION [DESTINATION ...]')
            return 2
        return route(p, argv[3], argv[4:])
    return filt(p)


if __name__ == '__main__':
    sys.exit(main(sys.argv))
