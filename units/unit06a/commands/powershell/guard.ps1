# Reference commands. Read FOLLOW-ALONG.md first. Run ONE step at a time on YOUR computer.
# Set settings/identity first for AWS reads. REPLACE values are mandatory.
$CostAck = "NO"
$EndTime = "REPLACE_WITH_FUTURE_ISO8601_WITH_OFFSET"
py -3 scripts/check_guard.py --expected-account "$ExpectedAccount" --actual-account "$ActualAccount" --cost-ack "$CostAck" --end-time "$EndTime"
if ($LASTEXITCODE -ne 0) { throw "STOP: local guard failed" }
