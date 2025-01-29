# BASION-HOST VM-INSTANCE
module "gke-mgmt" {
  source          = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/compute-vm?ref=v36.1.0"
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
  options = {
    spot               = true
    termination_action = "STOP"
  }
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


module "fw-rule" {
  source     = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/net-vpc-firewall?ref=v36.1.0"
  project_id = var.project_id
  network    = var.vpc_id
  ingress_rules = [{
    description        = "Allow SSH for IAP tunnel"
    targets            = ["allow-iap-tunnel"]
    source_ranges      = ["35.35.240.0/20"]
    rules              = [{ protocol = "tcp", ports = ["22"] }]
    destination_ranges = [module.gke-mgmt.internal_ip]
    }
  ]
}

