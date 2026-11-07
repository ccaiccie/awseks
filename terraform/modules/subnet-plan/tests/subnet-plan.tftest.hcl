run "sixteen_two_azs_do_not_overlap" {
  command = plan

  variables {
    vpc_cidr = "10.0.0.0/16"
    az_count = 2
  }

  assert {
    condition     = length(output.private_subnets) == 2 && output.private_subnets[0] == "10.0.0.0/19" && output.public_subnets[0] == "10.0.96.0/24"
    error_message = "Expected /19 private subnets and /24 public subnets starting at 10.0.96.0/24."
  }
}

run "three_azs_keep_public_past_private" {
  command = plan

  variables {
    vpc_cidr = "10.40.0.0/16"
    az_count = 3
  }

  assert {
    condition     = output.private_subnets[2] == "10.40.64.0/19" && output.public_subnets[2] == "10.40.98.0/24"
    error_message = "The third public subnet collided with the private range."
  }
}

run "rejects_one_az" {
  command = plan

  variables {
    vpc_cidr = "10.0.0.0/16"
    az_count = 1
  }

  expect_failures = [
    var.az_count,
  ]
}
