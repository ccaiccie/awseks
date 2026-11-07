locals {
  left_prefix  = tonumber(split("/", var.left)[1])
  right_prefix = tonumber(split("/", var.right)[1])
  left_start   = local.ipv4_to_number[cidrhost(var.left, 0)]
  right_start  = local.ipv4_to_number[cidrhost(var.right, 0)]
  left_size    = pow(2, 32 - local.left_prefix)
  right_size   = pow(2, 32 - local.right_prefix)

  ipv4_to_number = {
    for addr in [cidrhost(var.left, 0), cidrhost(var.right, 0)] :
    addr => (
      tonumber(split(".", addr)[0]) * 16777216 +
      tonumber(split(".", addr)[1]) * 65536 +
      tonumber(split(".", addr)[2]) * 256 +
      tonumber(split(".", addr)[3])
    )
  }
}
