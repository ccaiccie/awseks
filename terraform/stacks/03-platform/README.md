# Stack 03 — platform

Apply only after `kubectl get nodes` shows both nodes Ready. The Helm and Kubernetes providers call `aws eks get-token` against the live API.

This stack installs metrics-server and the AWS Load Balancer Controller, and it creates the lab 08 bucket plus two roles. It does not create a load balancer. Labs 09 and 10 do that with kubectl.

EFS stays off until `enable_efs = true` and `efs_confirmation = "enable-efs"`.

metrics-server is installed with `--kubelet-insecure-tls` because EKS kubelet certificates are not in the chart's default trust. That skips kubelet TLS verification. It is a lab shortcut.
