#!/usr/bin/env python3
"""Local rehearsal gate. Does not schedule deletion, enforce a spending cap or call AWS."""
import argparse,datetime,re
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--expected-account',required=True)
p.add_argument('--actual-account',required=True)
p.add_argument('--cost-ack',required=True)
p.add_argument('--end-time',required=True,help='ISO8601 with explicit offset, e.g. 2026-11-08T16:00:00-08:00')
a=p.parse_args()
if not re.fullmatch(r'\d{12}',a.expected_account):raise SystemExit('STOP: expected account must be 12 digits')
if a.expected_account!=a.actual_account:raise SystemExit('STOP: wrong account')
if a.cost_ack!='I_ACCEPT_BILLABLE_RESOURCES_IN_UNIT6B':raise SystemExit('STOP: cost not acknowledged')
try: end=datetime.datetime.fromisoformat(a.end_time.replace('Z','+00:00'))
except ValueError:raise SystemExit('STOP: invalid ISO8601 end time')
if end.tzinfo is None:raise SystemExit('STOP: end time needs an explicit UTC offset')
now=datetime.datetime.now(datetime.timezone.utc)
if not now<end<=now+datetime.timedelta(hours=8):raise SystemExit('STOP: end time must be in next eight hours')
print('PASS local rehearsal gate only. No automatic cleanup is scheduled; no AWS resources were created.')
