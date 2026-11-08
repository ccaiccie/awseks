#!/usr/bin/env python3
"""Offline IPv4 teaching checks; no AWS SDK, credentials or network calls."""
import argparse, ipaddress, json
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--vpc', default='10.42.0.0/16')
p.add_argument('--service', default='172.20.0.0/16')
p.add_argument('--private', default='10.42.16.0/20')
p.add_argument('--destination', default='10.42.16.21')
a=p.parse_args()
vpc=ipaddress.ip_network(a.vpc);service=ipaddress.ip_network(a.service);subnet=ipaddress.ip_network(a.private)
private_ranges=[ipaddress.ip_network(c) for c in ['10.0.0.0/8','172.16.0.0/12','192.168.0.0/16']]
if any(n.version != 4 for n in [vpc,service,subnet]): raise SystemExit('STOP: IPv4 teaching exercise only')
if not any(service.subnet_of(n) for n in private_ranges): raise SystemExit('STOP: Service range must be RFC1918')
if not 12 <= service.prefixlen <= 24: raise SystemExit('STOP: Service prefix must be /12 through /24')
if service.overlaps(vpc): raise SystemExit('STOP: Service and VPC ranges overlap')
if not subnet.subnet_of(vpc): raise SystemExit('STOP: private subnet is not inside the VPC')
if not 16 <= subnet.prefixlen <= 28: raise SystemExit('STOP: AWS IPv4 subnet prefix must be /16 through /28')
usable=subnet.num_addresses-5
node_reservation=(2+2)*3*10
other=4+4+8+1+6
planned=node_reservation+other
routes=[(ipaddress.ip_network('0.0.0.0/0'),'NAT in same AZ'),(vpc,'local')]
destination=ipaddress.ip_address(a.destination)
matches=sorted([(n,t) for n,t in routes if destination in n],key=lambda x:x[0].prefixlen,reverse=True)
print(json.dumps({'label':'ILLUSTRATIVE OFFLINE RESULT, NOT CURRENT AWS ACCOUNT', 'usable':usable,'node_reservation':node_reservation,'other':other,'planned':planned,'remaining':usable-planned,'pass_50_percent_headroom':planned<=usable*0.5,'route_destination':str(destination),'candidates':[{'prefix':str(n),'target':t} for n,t in matches],'winner':str(matches[0][0]) if matches else None,'nacl_example':{'request_destination_port':443,'return_destination_port':40312,'inbound_only_443':'DENY return (implicit deny)','required_return_rule':'allow actual return ephemeral destination port range before deny'}},indent=2))
if planned>usable*0.5: raise SystemExit('STOP: illustration exceeds 50 percent planned usage')
