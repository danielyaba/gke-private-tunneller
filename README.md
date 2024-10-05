# GKE-Private-Tunneller
The guide shows how to connect to a private GKE cluster, leveraging a proxy and an IAP tunnel on Gooelc cloud.  

What do you do when you've deployed a private GKE cluster and you want to access it from your own local machine but you don't have a zero-trust infrastructure installed on your GKE cluster ?  
This is when tinyproxy comes to the rescue

### Pre-Requisuites
1. Ensure those tools are installed on your local machine:
  * [kubectl](https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl)
  * [gcloud](https://cloud.google.com/sdk/docs/install)
  * [gke-gcloud-auth-plugin](https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl)
  * [helm](https://helm.sh/)

2. Ensure this alias is configured in your `~/.bashrc` or `~/.zshrc` file:
```
alias kubectl='kubectl'
alias helm='helm'
```
Also you can add some other aliases of `kubectl` which might be usefull:
```
alias k='kubectl'
alias ka='kubectl apply -f'
alias kd='kubectl describe'
alias kg='kubectl get'
alias kl='kubectl logs'
alias kgp='kubectl get pods'
alias kdp='kubectl describe pods'
alias kubens='kubens'
```


## Install TinyProxy VM-Instance
#### Deploying With Terraform
You can use the Terraform code in the directory `./terraform` to deploy the vm-instance which installs TinyProxy.  
Fill free to adjust the code to your needs and add it to your infrastrcture code. 

#### Manual Installation
After installing the bastion host (a vm-instance) inside the same VPC of the GKE cluster which has connectivity to the Kubernets API server all we need to do on the bastion is just to install TinyProxy and add `allow 'localhost'` in the TinyProxy config file.  

```
apt update
apt install -y tinyproxy
grep -qxF ‘Allow localhost’ /etc/tinyproxy/tinyproxy.conf || echo ‘Allow localhost’ >> /etc/tinyproxy/tinyproxy.conf
service tinyproxy restart
```

## Connect To GKE
1.  Add the GKE cluster to your kubeconfig on your local machine
```
gcloud container clusters get-credentials <GKE_CLUSTER_NAME> \
  --zone <GKE_CLUSTER_ZONE> \
  --project <GKE_CLUSTER_PROJECT> \
  --internal-ip
``` 

2. Create a tunnel to the bastion host using Google IAP tunnel
```
gcloud compute ssh gke-mgmt \
  --project <BASTION_HOST_PROJECT> \
  --zone <BASTION_HOST_ZONE> \
  -- -L 8888:localhost:8888 -N -q -f
```

3. Access the GKE API with kubectl commands using the proxy  
```
HTTPS_PROXY=localhost:8888 kubectl get namespaces
```
We should see an output of all namespaces in our private GKE cluster.  

## Using Some Automation
#### Prepare scripts
```
sudo cp gke_tunnel disable_gke_tunnel /usr/local/bin/
sudo chmod +x /usr/local/bin/gke_tunnel /usr/local/bin/disable_gke_tunnel
```

#### Using _gke_tunnel_ script
_gke_tunnel_ script is designed to connect to a vm-instance named `gke-mgmt` in the same project as the GKE private cluster.  
If _GKE_CLUSTER_NAME_ was provided to the script as second argument the script will connect directly to this cluster.  
If _GKE_CLUSTER_NAME_ wasn't provided then the script will let you choose a cluster from the project provided.  
It connects to the target bastion host through the IAP tunnel and edit all kubectl, kubens and helm aliases.  

```
gke_tunnel <BASTION_HOST_PROJECT> <GKE_CLUSTER_NAME>
```

#### Using _disable_gke_tunnel_ script
_disable_gke_tunnel_ script shuts tunnel down and edit kubectl, kubens and helm aliases without the `HTTPS_PROXY=localhost:8888`
```
disable_gke_tunnel
```