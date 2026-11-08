# Reference commands. Read FOLLOW-ALONG.md first. Run ONE step at a time on YOUR computer.
# Set settings/identity first for AWS reads. REPLACE values are mandatory.
aws budgets describe-budgets --profile "$AwsProfile" --region us-east-1 --account-id "$ExpectedAccount" --output json --no-cli-pager
$BudgetName = "unit06a-learning-alert"
aws budgets describe-notifications-for-budget --profile "$AwsProfile" --region us-east-1 --account-id "$ExpectedAccount" --budget-name "$BudgetName" --output json --no-cli-pager
