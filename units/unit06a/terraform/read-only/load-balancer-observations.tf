# Optional EXISTING load balancer chain; default empty sets make no such reads.
variable "existing_load_balancer_arns" {
  type    = set(string)
  default = []
}
variable "existing_listener_arns" {
  type    = set(string)
  default = []
}
variable "existing_listener_rule_arns" {
  type    = set(string)
  default = []
}
variable "existing_target_group_arns" {
  type    = set(string)
  default = []
}
data "aws_lb" "existing" {
  for_each = var.existing_load_balancer_arns
  arn      = each.value
}
data "aws_lb_listener" "existing" {
  for_each = var.existing_listener_arns
  arn      = each.value
}
data "aws_lb_listener_rule" "existing" {
  for_each = var.existing_listener_rule_arns
  arn      = each.value
}
data "aws_lb_target_group" "existing" {
  for_each = var.existing_target_group_arns
  arn      = each.value
}
output "load_balancer_observations" {
  value = { for arn, l in data.aws_lb.existing : arn => { dns = l.dns_name, type = l.load_balancer_type, internal = l.internal, vpc = l.vpc_id, subnets = l.subnets, security_groups = l.security_groups } }
}
output "listener_observations" {
  value = { for arn, l in data.aws_lb_listener.existing : arn => { load_balancer = l.load_balancer_arn, protocol = l.protocol, port = l.port, default_action_types = [for a in l.default_action : a.type] } }
}
output "listener_rule_observations" {
  value = { for arn, r in data.aws_lb_listener_rule.existing : arn => { listener = r.listener_arn, priority = r.priority, conditions = r.condition, action_types = [for a in r.action : a.type] } }
}
output "target_group_observations" {
  value       = { for arn, t in data.aws_lb_target_group.existing : arn => { protocol = t.protocol, port = t.port, target_type = t.target_type, vpc = t.vpc_id, health_check = t.health_check } }
  description = "Health-check policy, NOT live per-target health. Use CLI describe-target-health for actual target state/reason. State/plan and listener auth configuration remain private."
}
