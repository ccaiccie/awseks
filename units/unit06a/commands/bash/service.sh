# Reference commands. Read FOLLOW-ALONG.md first. Run ONE step at a time on YOUR computer.
# Set settings/identity first for AWS reads. REPLACE values are mandatory.
python3 scripts/network_checks.py --vpc 10.42.0.0/16 --service 172.20.0.0/16 --destination 172.20.0.10
# Deliberate failure, offline only:
python3 scripts/network_checks.py --vpc 10.42.0.0/16 --service 10.42.0.0/16
