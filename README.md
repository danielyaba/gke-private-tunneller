# GKE-Private-Tunneller
The guide shows how to connect to the control plane of a GKE private cluster, leveraging a proxy and an IAP tunnel.  

What do you do when you setup a private GKE cluster and you want to access it from your own local machine but your don't have a zero-trust infrastructure installed on your GKE cluster ?
This is when tinyproxy comes to the rescue

### Pre-Requisuites
Ensure those tools are installed in your local machine:
* kubectl
* gcloud

## Install TinyProxy VM-Instance
After you installing a bastion host inside the same VPC of the GKE cluster which has connectivity to the Kubernets API server all we need to do on the bastion host if just to install TinyProxy and add 'localhost' to be allowed in TinyProxy configuration file

```
apt update
apt install -y tinyproxy
Allow localhost
service tinyproxy restart
```

This can also be automated through an idempotent startup-script:
```
#! /bin/bash
apt-get update
apt-get install -y tinyproxy
grep -qxF ‘Allow localhost’ /etc/tinyproxy/tinyproxy.conf || echo ‘Allow localhost’ >> /etc/tinyproxy/tinyproxy.conf
service tinyproxy restart
```

## Connect To GKE
first add your GKE cluster to your local machine
```
gcloud container clusters get-credentials <GKE_CLUSTER_NAME> \
  --zone <GKE_CLUSTER_ZONE> \
  --project <GKE_CLUSTER_PROJECT> \
  --internal-ip
``` 

Now let's create a tunnel to the bation host with IAP
```
gcloud compute ssh <BASTION_HOST_NAME> \
  --project <BASTION_HOST_PROJECT> \
  --zone <BASTION_HOST_ZONE> \
  -- -L 8888:localhost:8888 -N -q -f
```

We can now access the GKE API with kubectl commands using the proxy  
```
HTTPS_PROXY=localhost:8888 kubectl get namespaces
```
We should we an output of all namespaces in our private GKE cluster.  

## Using Some Automation
#### Prepare scripts
```
git clone https://github.com/danielyaba/gke-private-tunneller.git && cd gke-private-tunneller
cp gke_tunnel disable_gke_tunnel /usr/local/bin/
chmod +x gke_tunnel disable_gke_tunnel
```

#### Using ```gke_tunnel``` script
```gke_tunnel``` script is designed to connect to a vm-instance named bastion-host in a project same projet as the GKE cluster.  
It connects to the target bastion host through the IAP tunnel and addes aliases to kubectl, kubens and helm commands.  

```
gke_tunnel <BASTION_HOST_PROJECT> <GKE_CLUSTER_NAME>
```

