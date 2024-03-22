# GKE-Private-Tunneller
The guide shows how to connect to the control plane of a GKE private cluster, leveraging a proxy and an IAP tunnel.  

What do you do when you setup a private GKE cluster and you want to access it from your own local machine but your don't have a zero-trust infrastructure installed on your GKE cluster ?
This is when tinyproxy comes to the rescue

### Pre-Requisuites
Ensure those tools are installed on your local machine:
* [kubectl](https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl)
* [gcloud](https://cloud.google.com/sdk/docs/install)

## Install TinyProxy VM-Instance
After installing a bastion host inside the same VPC of the GKE cluster which has connectivity to the Kubernets API server all we need to do on the bastion is just to install TinyProxy and add to allow 'localhost' in the TinyProxy config file (also can be automated through startup-script)

```
apt update
apt install -y tinyproxy
grep -qxF ‘Allow localhost’ /etc/tinyproxy/tinyproxy.conf || echo ‘Allow localhost’ >> /etc/tinyproxy/tinyproxy.conf
service tinyproxy restart
```

## Connect To GKE
1.  Add your GKE cluster to your local machine
```
gcloud container clusters get-credentials <GKE_CLUSTER_NAME> \
  --zone <GKE_CLUSTER_ZONE> \
  --project <GKE_CLUSTER_PROJECT> \
  --internal-ip
``` 

2. Create a tunnel to the bastion host using IAP
```
gcloud compute ssh <BASTION_HOST_NAME> \
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
git clone https://github.com/danielyaba/gke-private-tunneller.git && cd gke-private-tunneller
cp gke_tunnel disable_gke_tunnel /usr/local/bin/
chmod +x gke_tunnel disable_gke_tunnel
```

#### Using _gke_tunnel_ script
_gke_tunnel_ script is designed to connect to a vm-instance named bastion-host in the same projet as the GKE cluster.  
If GKE_CLUSTER_NAME was provided to the script as second argument the script will connect directly to this cluster.  
If GKE_CLUSTER_NAME wasn't provided then the script will let you choose a cluster from the project provided.  
It connects to the target bastion host through the IAP tunnel and addes aliases to kubectl, kubens and helm commands.  

```
gke_tunnel <BASTION_HOST_PROJECT> <GKE_CLUSTER_NAME>
```

#### Using _disable_gke_tunnel_ script
_disable_gke_tunnel_ script disconnects from the tunnel and removes all aliases.  
```
disable_gke_tunnel
```