output "latest_ips" {
  value = "${data.aws_instances.customer_instances}"
}

output "volumetags" {
  value = "${data.aws_ebs_volume.assigned_volumes}"
}

