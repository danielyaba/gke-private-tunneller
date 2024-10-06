output "instance_name" {
  value = module.gke-mgmt.name
  description = "The name of the instance."
}

output "instance_id" {
  value = module.gke-mgmt.id
  description = "The ID of the instance."
}

output "instance_internal_ip" {
  value = module.gke-mgmt.internal_ip
}

output "instance_service_account" {
  value = module.gke-mgmt.service_account
}