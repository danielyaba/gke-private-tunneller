# GKE-Private-Tunneller

![My Script Logo](assets/logo.png)

This guide shows how to connect to a private GKE cluster, using a proxy and an IAP tunnel on Google Cloud.

When you deploy a private GKE cluster and need to access it from your local machine but don’t have a zero-trust infrastructure in place, TinyProxy can help. This tool will enable access to your cluster via a proxy, allowing secure connections.

### Pre-Requisuites

Before proceeding, make sure you have the following tools installed:
1. [kubectl](https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl)
2. [gcloud](https://cloud.google.com/sdk/docs/install)
3. [gke-gcloud-auth-plugin](https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl)
4. [helm](https://helm.sh/)

Also, ensure the following aliases are set up in your ~/.bashrc or ~/.zshrc:
GKE-Private-Tunneller searches for `kubectl` aliases and modifies them to `HTTPS_PROXY=localhost:8888 kubectl`.   
```bash
alias kubectl='kubectl'
alias helm='helm'
```

You can also add more aliases for convenience:
```bash
alias k='kubectl'
alias ka='kubectl apply -f'
alias kd='kubectl describe'
alias kg='kubectl get'
alias kl='kubectl logs'
alias kgp='kubectl get pods'
alias kdp='kubectl describe pods'
alias kubens='kubens'
alias k9s='k9s'
```

## Install TinyProxy VM-Instance
#### Deploying With Terraform
You can deploy the TinyProxy VM instance using the Terraform code in the ./terraform directory.  
Feel free to adjust the code to fit your infrastructure.  

#### Manual Installation
If you prefer a manual approach, you can set up a bastion host (a VM instance in the same VPC as the GKE cluster) and install TinyProxy:
```bash
apt update
apt install -y tinyproxy
grep -qxF ‘Allow localhost’ /etc/tinyproxy/tinyproxy.conf || echo ‘Allow localhost’ >> /etc/tinyproxy/tinyproxy.conf
service tinyproxy restart
```

## Connect To GKE
1.  Add the GKE cluster to your kubeconfig:  
```bash
gcloud container clusters get-credentials <GKE_CLUSTER_NAME> \
  --zone <GKE_CLUSTER_ZONE> \
  --project <GKE_CLUSTER_PROJECT> \
  --internal-ip
``` 

2. Create a tunnel to the bastion host via the IAP tunnel:
```bash
gcloud compute ssh gke-mgmt \
  --project <BASTION_HOST_PROJECT> \
  --zone <BASTION_HOST_ZONE> \
  -- -L 8888:localhost:8888 -N -q -f
```

3. Access the GKE API with kubectl through the proxy:
```bash
HTTPS_PROXY=localhost:8888 kubectl get namespaces
```

You should now see the namespaces in your private GKE cluster.  

## Using Some Automation
#### Prepare scripts
To automate the process, you can copy the following scripts to /usr/local/bin/:  
```bash
sudo cp gke_tunnel disable_gke_tunnel /usr/local/bin/
sudo chmod +x /usr/local/bin/gke_tunnel /usr/local/bin/disable_gke_tunnel
```

You can also use symlinks with a custom aliases file. Check [Custom configuration file](#configuration-file) section for more details.   

#### Using _gke_tunnel_ script
The gke_tunnel script connects to the gke-mgmt VM instance and sets up the proxy tunnel. It will automatically update the kubectl, kubens, and helm aliases to route traffic through the proxy.  
If a cluster_name is provided as a second argument, the script will connect to that specific cluster. If not, it will allow you to choose from available clusters in the project.
Example usage:
```bash
gke_tunnel --project_id=<BASTION_HOST_PROJECT> --cluster_name=<GKE_CLUSTER_NAME>
```

#### Using _disable_gke_tunnel_ script
To shut down the tunnel and reset the aliases:
```bash
disable_gke_tunnel
```

#### Configuration File
If you prefer using symlinks or have custom alias files not located in ~/.bashrc or ~/.zshrc, you can use a configuration file.   
By default, the script looks for a configuration file at ~/.config/private-gke-tunneller/config.toml.  
Example configuration:
```
[kubectl]
aliases_file = "path/to/aliases-file"

[helm]
aliases_file = "path/to/aliases-file"
```

If this configuration file is missing, the script will fall back to the default ~/.bashrc or ~/.zshrc files.   

If you want to use a custom path for the configuration file, you can set the following in your ~/.bashrc or ~/.zshrc:
```bash
export PRIVATE_GKE_TUNNELLER_CONFIG="<path/to/config-file.toml>"
```

