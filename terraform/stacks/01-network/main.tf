locals {
  tags = {
    Project    = "awseks-practice"
    ManagedBy  = "terraform"
    Stack      = "01-network"
    NamePrefix = var.name
    CostCenter = "eks-networking-masterclass"
  }

  azs = length(var.availability_zone_names) > 0 ? var.availability_zone_names : slice(data.aws_availability_zones.available[0].names, 0, var.az_count)
}

module "guardrails" {
  source = "../../modules/guardrails"

  name = var.name

  check_confirmation    = true
  confirmation_enabled  = var.enable_interface_endpoints
  confirmation_value    = var.interface_endpoint_confirmation
  confirmation_expected = "enable-interface-endpoints"
}

module "subnet_plan" {
  source = "../../modules/subnet-plan"

  vpc_cidr = var.vpc_cidr
  az_count = var.az_count
}

data "aws_availability_zones" "available" {
  count = length(var.availability_zone_names) == 0 ? 1 : 0

  state = "available"

  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

resource "terraform_data" "az_count_guard" {
  lifecycle {
    precondition {
      condition     = length(local.azs) == var.az_count
      error_message = "availability_zone_names must contain exactly az_count entries, or the Region must have at least az_count AZs."
    }
    precondition {
      condition     = length(distinct(local.azs)) == length(local.azs)
      error_message = "Availability Zone names must be unique."
    }
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.7.3"

  name = "${var.name}-vpc"
  cidr = var.vpc_cidr
  azs  = local.azs

  private_subnets = module.subnet_plan.private_subnets
  public_subnets  = module.subnet_plan.public_subnets

  enable_dns_hostnames = true
  enable_dns_support   = true
  create_igw           = true

  enable_nat_gateway     = true
  single_nat_gateway     = !var.nat_gateway_per_az
  one_nat_gateway_per_az = var.nat_gateway_per_az

  map_public_ip_on_launch = true

  manage_default_security_group  = true
  default_security_group_ingress = []
  default_security_group_egress  = []

  enable_flow_log                                 = var.enable_flow_logs
  create_flow_log_cloudwatch_log_group            = var.enable_flow_logs
  create_flow_log_cloudwatch_iam_role             = var.enable_flow_logs
  flow_log_destination_type                       = "cloud-watch-logs"
  flow_log_traffic_type                           = "ALL"
  flow_log_max_aggregation_interval               = 600
  flow_log_cloudwatch_log_group_retention_in_days = 1
  flow_log_cloudwatch_log_group_skip_destroy      = false

  public_subnet_tags = {
    "kubernetes.io/role/elb"      = "1"
    "awseks.practice/subnet-role" = "public-lb"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
    "awseks.practice/subnet-role"     = "private-worker"
  }

  tags = local.tags

  depends_on = [terraform_data.az_count_guard]
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = module.vpc.private_route_table_ids

  tags = merge(local.tags, {
    Name = "${var.name}-s3"
  })
}

resource "aws_security_group" "interface_endpoints" {
  count = var.enable_interface_endpoints ? 1 : 0

  name        = "${var.name}-vpce"
  description = "HTTPS from the practice VPC to interface VPC endpoints"
  vpc_id      = module.vpc.vpc_id

  tags = merge(local.tags, {
    Name = "${var.name}-vpce"
  })
}

resource "aws_vpc_security_group_ingress_rule" "interface_endpoints_https" {
  count = var.enable_interface_endpoints ? 1 : 0

  security_group_id = aws_security_group.interface_endpoints[0].id
  description       = "HTTPS from the practice VPC CIDR"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = var.vpc_cidr
}

resource "aws_vpc_security_group_egress_rule" "interface_endpoints_vpc" {
  count = var.enable_interface_endpoints ? 1 : 0

  security_group_id = aws_security_group.interface_endpoints[0].id
  description       = "Return traffic into the practice VPC"
  ip_protocol       = "-1"
  cidr_ipv4         = var.vpc_cidr
}

resource "aws_vpc_endpoint" "interface" {
  for_each = var.enable_interface_endpoints ? toset(var.interface_endpoint_services) : toset([])

  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${var.region}.${each.value}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = module.vpc.private_subnets
  security_group_ids  = [aws_security_group.interface_endpoints[0].id]
  private_dns_enabled = true

  tags = merge(local.tags, {
    Name = "${var.name}-${replace(each.value, ".", "-")}"
  })
}
