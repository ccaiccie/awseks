# Lab 12 — TLS with ACM and a domain you own

## Objective

Terminate TLS on the ALB with a certificate in this account, for a name you control in Route 53. Skip this lab if you do not have that domain. Do not invent `example.com` and expect ACM to validate it.

## Architecture

The client speaks TLS to the ALB. The certificate is in ACM in the same Region as the load balancer. The ALB to pod hop stays HTTP on the pod port in this sample. That is a class simplification, not a claim that the pod network is a trust boundary.

Terraform does not create the certificate or the DNS record. Those objects are the AWS CLI track so they are not duplicated in state. Delete them yourself.

## Prerequisites

Lab 09's namespace and Deployment are up, the IP-mode Ingress is deleted, and stack 03's controller is Ready. A public hosted zone for your domain is already in this account. This lab does not register a domain.

## Steps

Request a DNS-validated certificate. Replace the names.

```bash
aws acm request-certificate \
  --domain-name "app.YOURDOMAIN" \
  --validation-method DNS \
  --region "$AWS_REGION"
aws acm describe-certificate --certificate-arn "$CERT_ARN" \
  --query 'Certificate.DomainValidationOptions'
```

Create the validation CNAME in your hosted zone from the `ResourceRecord` in that output. Wait until the certificate status is `ISSUED`.

Edit `manifests/lab12-tls/ingress-https.yaml`. Replace the certificate ARN and the host. Apply it.

```bash
kubectl apply -f manifests/lab12-tls/ingress-https.yaml
curl -sS "https://app.YOURDOMAIN/"
```

The Route 53 alias to the ALB hostname is also yours to create. Use an alias A record to the dualstack hostname of the Ingress. Do not point the name at a pod IP.

## Expected observations

Example only, and only if the certificate is `ISSUED` and DNS matches the Ingress host. `curl` prints `practice web` and the certificate subject is your name. A browser warning means DNS reached a different load balancer or the certificate is still `PENDING_VALIDATION`.

## Questions

1. Why is the certificate Regional?
2. What does the annotation `alb.ingress.kubernetes.io/certificate-arn` change, and what does it not change inside the pod?
3. Why is this file rejected as a class default?

## Failure injection

None. A bad certificate ARN fails in the controller log. Fix the annotation. Do not open security group 443 to the world by hand. The controller manages the listener security group.

## Diagnostics

`PENDING_VALIDATION` for more than a few minutes: the CNAME is in the wrong hosted zone or the name does not match ACM's record. Ingress has an address but `curl` cannot resolve your host: the alias record is missing. TLS handshake uses a default AWS certificate: the annotation did not apply. `kubectl describe ingress -n lab-ingress web-tls`.

## Answers

1. ACM certificates for an ALB must be in the same Region as the ALB. A us-east-1 certificate does not attach to a us-west-2 load balancer. CloudFront is the exception people confuse this with, and this lab is not CloudFront.
2. It selects the certificate on the HTTPS listener. The pod still receives HTTP from the ALB in this manifest. The pod does not see the client certificate.
3. It contains `REPLACE_REGION` and `REPLACE_WITH_OWNED_DOMAIN`. Applying it unchanged makes a broken Ingress. The lab is optional.

## Cleanup

```bash
kubectl delete -f manifests/lab12-tls/ingress-https.yaml
aws acm delete-certificate --certificate-arn "$CERT_ARN"
```

Delete the alias and the validation CNAME. Terraform will not do that.

## Cost

ACM public certificates have no certificate fee. The ALB from the Ingress is the charge. DNS queries on the hosted zone are small. A domain registration, if you buy one, is a separate purchase this lab does not ask for.
