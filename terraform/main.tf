# BASION-HOST VM-INSTANCE
module "gke-mgmt" {
  source          = "https://github.com/GoogleCloudPlatform/cloud-foundation-fabric/tree/master/modules/compute-vm"
  project_id      = var.project_id
  zone            = "${var.region}-a"
  name            = "gke-mgmt"
  instance_type   = "e2-medium"
  service_account = var.service_account
  tags            = var.tags
  labels          = var.labels
  network_interfaces = [{
    network    = var.vpc_id
    subnetwork = var.subnet_id
  }]
  service_account_scopes = [
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/userinfo.email",
  ]
  metadata = {
    startup-script = <<-EOF
      #!/bin/bash
      apt-get update
      apt-get install -y tinyproxy
      grep -qxF 'Allow localhost' /etc/tinyproxy/tinyproxy.conf || echo 'Allow localhost' >> /etc/tinyproxy/tinyproxy.conf
      service tinyproxy restart
    EOF
  }
}