# What is this
This is the Kubernetes the Hard Way content transformed to vagrant & ansible, designated for local VirtualBox deployment. 
For educational purposes.

# Requirements
- Kubernetes the Hard Way client tools (tested on https://raw.githubusercontent.com/kelseyhightower/kubernetes-the-hard-way/79a3f79b27bd28f82f071bb877a266c2e62ee506/docs/02-client-tools.md)
- Linux (tested on Ubuntu 20.04 LTS on WSL2)
- VirtualBox (tested on 7.0.2 Windows)
- ansible (tested on version 2.13.5)
- vagrant (tested on version 2.3.2)
- jq (tested on version 1.6)

Idle cluster resource requirements: `number_of_nodes * 1GB` of RAM. So 3GB for minimal setup, 7GB for standard 3x3 cluster.

# Configure
There shouldn't be any hardcoded elements in scripts, you can manage everything using single `config.json`.
Config description:
- `vm_box` - OS of VMs (nodes). **Do not change** from ubuntu 20.04 unless you have some free time. I tried Ubuntu 22.04 but stumbled upon cgroupv2 issue, probably updating k8s to 1.22+ would help here.
- `ssh_pub_key_path` - Path to your local SSH pub key used to talk to VMs (nodes) with SSH.
- `assets_dir` - This folder will contain everything that gets uploaded to nodes. **Do not delete it** if it is populated and cluster is running.
- `ansible_inventory_file` - The file name which will have ansible inventory to be utilized in playbooks.
- `etc_hosts_file` - The file name which will be uploaded to all nodes.
- `kubeconfig_context` - Context name used in kubeconfig.
- `cluster_cidr` - K8S setting, CIDR of the whole cluster. Theoretically it should encompass all `pod_cidr` values (but cluster will work even if it doesn't).
- `service_cluster_ip_range` - K8S setting, CIDR used to provision cluster IP services.
- `masters` - List of hostnames and IP addresses of k8s master nodes - this is where you also control the number of master nodes.
- `workers` - List of hostnames, IP addresses, POD cidrs (pod subnet which should be a cluster CIDR subnet) of k8s worker nodes - this is where you also control the number of worker nodes.
- `proxy` - Hostname and ip address for nginx TCP proxy (separate VM) which load balances traffic to API servers on master nodes.

# Run
```
vagrant up
```
And wait about 8 minutes. 
Normally, there shouldn't be any errors nor warnings.
Note that non-deterministic errors are more likely on more machines.

# Access
## Access nodes with SSH
```
ssh vagrant@ONE_OF_VM_IP_ADDRESSES_FROM_CONFIG_JSON -i PATH_TO_YOUR_SSH_PUB_KEY_FROM_CONFIG_JSON
```
You could also use hostnames for simplicity, content that should go to etc hosts is generated for you:
```
cat ASSETS_DIR_FROM_CONFIG_JSON/_APPEND_THIS_TO_ETC_HOSTS >> /etc/hosts
```
## kubectl
Update your kubeconfig using `update_kubeconfig.sh` script
Then you should be able to easily access cluster via kubectl - just remember that kubeconfig relies on a cert that resides in assets dir, so don't delete this dir.

# Testing
Spin up:
```
kubectl apply -f _example_deployment.yaml
kubectl run multitool --image=praqma/network-multitool
```
Check internal DNS:
```
$ kubectl exec multitool -- nslookup kubernetes
Server:         10.32.0.10
Address:        10.32.0.10#53

Name:   kubernetes.default.svc.cluster.local
Address: 10.32.0.1
```
Check external DNS:
```
$ kubectl exec multitool -- nslookup radiomaryja.pl
(some reasonable response, do not enter)
```
Curl example deployment service (*do it multiple times if you have multiple nodes to check inter-node connectivity*):
```
$ kubectl exec multitool -- curl -sI nginx-service
HTTP/1.1 200 OK
Server: nginx/1.14.2
(...)
```
Curl nodeport service from your host (*recommended to do it for all VMs*):
```
curl -sI ONE_OF_VM_IP_ADDRESSES_FROM_CONFIG_JSON:30007
HTTP/1.1 200 OK
Server: nginx/1.14.2
```
Print super secret secret:
```
$ kubectl exec deploy/nginx-deployment -- cat dupa/SUPER_SECRET
This is a good value
```

If any command returns something else, there is something wrong (no shit sherlock).
Also, Kubernetes the Hard Way contains some other smoke test instructions.

# Tear down
```
vagrant destroy
rm -fr .assets .vagrant
```

# Troubleshooting
Cigarettes and reverse engineering
