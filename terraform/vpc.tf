resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.cluster_name}-vpc"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.cluster_name}-igw"
  }
}

resource "aws_subnet" "public" {
  count = var.az_count

  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.public_subnet_cidrs[count.index]
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name                     = "${var.cluster_name}-public-${local.azs[count.index]}"
    "kubernetes.io/role/elb" = "1"
    Tier                     = "public"
  }
}

resource "aws_subnet" "private" {
  count = var.az_count

  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.private_subnet_cidrs[count.index]
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name                              = "${var.cluster_name}-private-${local.azs[count.index]}"
    "kubernetes.io/role/internal-elb" = "1"
    Tier                              = "private"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.cluster_name}-public"
  }
}

resource "aws_route" "public_default" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  count = var.az_count

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  count = local.nat_gateway_count

  domain = "vpc"

  depends_on = [aws_internet_gateway.this]

  tags = {
    Name = "${var.cluster_name}-nat-${count.index}"
  }
}

resource "aws_nat_gateway" "this" {
  count = local.nat_gateway_count

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[var.nat_strategy == "single" ? 0 : count.index].id

  tags = {
    Name = "${var.cluster_name}-nat-${count.index}"
  }

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route_table" "private_shared" {
  count = var.nat_strategy == "per_az" ? 0 : 1

  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.cluster_name}-private-shared"
  }
}

resource "aws_route" "private_shared_default" {
  count = var.nat_strategy == "single" ? 1 : 0

  route_table_id         = aws_route_table.private_shared[0].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[0].id
}

resource "aws_route_table_association" "private_shared" {
  count = var.nat_strategy == "per_az" ? 0 : var.az_count

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_shared[0].id
}

resource "aws_route_table" "private_per_az" {
  count = var.nat_strategy == "per_az" ? var.az_count : 0

  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.cluster_name}-private-${local.azs[count.index]}"
  }
}

resource "aws_route" "private_per_az_default" {
  count = var.nat_strategy == "per_az" ? var.az_count : 0

  route_table_id         = aws_route_table.private_per_az[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[count.index].id
}

resource "aws_route_table_association" "private_per_az" {
  count = var.nat_strategy == "per_az" ? var.az_count : 0

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_per_az[count.index].id
}

resource "aws_security_group" "api_from_vpc" {
  name_prefix = "${var.cluster_name}-api-"
  description = "In-VPC clients to the private EKS API on TCP 443"
  vpc_id      = aws_vpc.this.id

  tags = {
    Name = "${var.cluster_name}-api"
  }
}

resource "aws_vpc_security_group_ingress_rule" "api_https" {
  for_each = toset(local.api_ingress_cidrs)

  security_group_id = aws_security_group.api_from_vpc.id
  description       = "Private Kubernetes API from an approved in-VPC CIDR"
  cidr_ipv4         = each.value
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "api_to_vpc" {
  security_group_id = aws_security_group.api_from_vpc.id
  description       = "Return traffic inside the VPC. Node paths use the EKS cluster security group."
  cidr_ipv4         = var.vpc_cidr
  ip_protocol       = "-1"
}

resource "aws_security_group" "endpoints" {
  name_prefix = "${var.cluster_name}-endpoints-"
  description = "HTTPS from the VPC to interface VPC endpoints"
  vpc_id      = aws_vpc.this.id

  tags = {
    Name = "${var.cluster_name}-endpoints"
  }
}

resource "aws_vpc_security_group_ingress_rule" "endpoints_https" {
  security_group_id = aws_security_group.endpoints.id
  description       = "HTTPS from the lab VPC to AWS interface endpoints"
  cidr_ipv4         = var.vpc_cidr
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}
