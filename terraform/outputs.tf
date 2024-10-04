output "instance_name" {
  value = module.compute-vm.name
  description = "The name of the instance."
}

output "instance_id" {
  value = module.compute-vm.id
  description = "The ID of the instance."
}

