output "overlaps" {
  value = (
    local.left_start < local.right_start + local.right_size &&
    local.right_start < local.left_start + local.left_size
  )
}
