"""Local comparison only. Inputs must come from successful authorized reads, not examples."""
import ipaddress,sys
if len(sys.argv)!=3:raise SystemExit('Usage: service_membership.py ACTUAL_SERVICE_CIDR ACTUAL_CLUSTER_IP')
try:
 network=ipaddress.ip_network(sys.argv[1],strict=True)
 if sys.argv[2] in ('','None'):
  print('SKIP ordinary-IP membership: check headless/ExternalName Service type.');raise SystemExit(0)
 address=ipaddress.ip_address(sys.argv[2]);inside=address in network
 print(f'ClusterIP {address} in actual Service pool {network}: {inside}')
 if not inside:raise SystemExit('STOP: address is outside the actual Service pool')
except ValueError as e:raise SystemExit('STOP: invalid address/range readout: '+str(e))
