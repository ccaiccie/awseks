# Reference commands. Read FOLLOW-ALONG.md first. Run ONE step at a time on YOUR computer.
# Set settings/identity first for AWS reads. REPLACE values are mandatory.
python3 scripts/network_checks.py --vpc 10.42.0.0/16 --service 172.20.0.0/16 --private 10.42.16.0/20
python3 scripts/network_checks.py --vpc 10.42.0.0/16 --service 172.20.0.0/16 --private 10.42.16.0/24
