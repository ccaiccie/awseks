run "accepts_private_api_and_small_nodes" {
  command = plan

  variables {
    name                         = "lab1"
    check_endpoint               = true
    endpoint_private_access      = true
    endpoint_public_access       = false
    endpoint_public_access_cidrs = []
    check_admin_principals       = true
    admin_principal_arns         = ["arn:aws:iam::111122223333:role/eks-lab-operator"]
    check_nodes                  = true
    node_instance_types          = ["t3.medium"]
    allow_expensive_nodes        = false
    node_min_size                = 2
    node_desired_size            = 2
    node_max_size                = 3
    check_kubernetes_version     = true
    kubernetes_version           = "1.35"
  }
}

run "accepts_explicit_public_cidr" {
  command = plan

  variables {
    name                         = "lab1"
    check_endpoint               = true
    endpoint_private_access      = true
    endpoint_public_access       = true
    endpoint_public_access_cidrs = ["203.0.113.10/32"]
    check_admin_principals       = false
    check_nodes                  = false
    check_kubernetes_version     = false
  }
}

run "rejects_world_open_api" {
  command = plan

  variables {
    name                         = "lab1"
    check_endpoint               = true
    endpoint_public_access       = true
    endpoint_public_access_cidrs = ["0.0.0.0/0"]
  }

  expect_failures = [
    var.endpoint_public_access_cidrs,
  ]
}

run "rejects_public_api_without_cidrs" {
  command = plan

  variables {
    name                         = "lab1"
    check_endpoint               = true
    endpoint_public_access       = true
    endpoint_public_access_cidrs = []
  }

  expect_failures = [
    var.endpoint_public_access_cidrs,
  ]
}

run "rejects_account_root" {
  command = plan

  variables {
    name                   = "lab1"
    check_admin_principals = true
    admin_principal_arns   = ["arn:aws:iam::111122223333:root"]
  }

  expect_failures = [
    var.admin_principal_arns,
  ]
}

run "rejects_micro_and_gpu_nodes" {
  command = plan

  variables {
    name                  = "lab1"
    check_nodes           = true
    node_instance_types   = ["p5.48xlarge"]
    allow_expensive_nodes = false
  }

  expect_failures = [
    var.allow_expensive_nodes,
  ]
}

run "rejects_single_node_lab" {
  command = plan

  variables {
    name              = "lab1"
    check_nodes       = true
    node_min_size     = 1
    node_desired_size = 1
    node_max_size     = 1
  }

  expect_failures = [
    var.allow_large_node_count,
  ]
}

run "rejects_unknown_kubernetes_version" {
  command = plan

  variables {
    name                     = "lab1"
    check_kubernetes_version = true
    kubernetes_version       = "1.33"
  }

  expect_failures = [
    var.kubernetes_version,
  ]
}

run "rejects_opt_in_without_confirmation" {
  command = plan

  variables {
    name                  = "lab1"
    check_confirmation    = true
    confirmation_enabled  = true
    confirmation_value    = "yes"
    confirmation_expected = "enable-karpenter"
  }

  expect_failures = [
    var.confirmation_expected,
  ]
}
