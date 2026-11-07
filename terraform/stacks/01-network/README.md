# Stack 01 — network

Creates the practice VPC. See the repository README for the apply sequence and `docs/COST.md` for the NAT choice.

Outputs consumed by stack 02 are `vpc_id`, `vpc_cidr`, and `private_subnet_ids`. Stack 02 reads them from this directory's local state unless you set `use_network_remote_state = false` and pass the ids yourself.

Do not point stack 02 at a different VPC that was not created here. The subnet tags `awseks.practice/subnet-role` and the Kubernetes ELB role tags are part of the contract.
