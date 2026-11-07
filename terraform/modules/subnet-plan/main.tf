locals {
  # /16 + 3 new bits = /19 (about 8190 addresses) for VPC CNI secondary IPs.
  # /17 + 3 = /20, /18 + 3 = /21. Public LB subnets use 8 extra bits and start
  # at net number 96, which sits just past the first three private blocks.
  private_newbits = 3
  public_newbits  = 8
  public_base     = 96

  private_subnets = [for index in range(var.az_count) : cidrsubnet(var.vpc_cidr, local.private_newbits, index)]
  public_subnets  = [for index in range(var.az_count) : cidrsubnet(var.vpc_cidr, local.public_newbits, local.public_base + index)]

  private_overlaps_public = anytrue(flatten([
    for private_cidr in local.private_subnets : [
      for public_cidr in local.public_subnets : module.overlap["${private_cidr}-${public_cidr}"].overlaps
    ]
  ]))
}

module "overlap" {
  source   = "../cidr-overlap"
  for_each = { for pair in setproduct(local.private_subnets, local.public_subnets) : "${pair[0]}-${pair[1]}" => pair }

  left  = each.value[0]
  right = each.value[1]
}

resource "terraform_data" "subnet_overlap_guard" {
  input = {
    private_subnets = local.private_subnets
    public_subnets  = local.public_subnets
  }

  lifecycle {
    precondition {
      condition     = !local.private_overlaps_public
      error_message = "Calculated private and public subnet CIDRs overlap. Choose a /16, /17, or /18 VPC CIDR and leave the subnet math unchanged."
    }
  }
}
