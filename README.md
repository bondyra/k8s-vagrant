# What is this
This is the Kubernetes the Hard Way content (https://github.com/kelseyhightower/kubernetes-the-hard-way) transformed to vagrant & ansible, designated for local VirtualBox deployment. 
For educational purposes.

# Requirements
- Kubernetes the Hard Way client tools (tested on https://raw.githubusercontent.com/kelseyhightower/kubernetes-the-hard-way/79a3f79b27bd28f82f071bb877a266c2e62ee506/docs/02-client-tools.md)
- Linux (tested on Ubuntu 20.04 LTS on WSL2 Win10)
- VirtualBox (tested on 7.0.2 Windows)
- ansible (tested on version 2.13.5)
- vagrant (tested on version 2.3.2)
- yq (tested on version 4.30.5)
- jq (tested on version 1.6)

Idle cluster resource requirements: `number_of_nodes * 1GB` of RAM. So 3GB for minimal setup, 7GB for standard 3x3 cluster.

# Configure
There shouldn't be any hardcoded elements in scripts, you can manage everything using single `config.yml` file. Config contains comments that explain how to use it.

# Run
```
vagrant up
```
This will do following things:
- Create in this folder a folder with PKI (only if it doesn't exist) using vagrant trigger script
- Create in this folder few other required or just handy local files using vagrant trigger script
- Create VirtualBox machines
- Upload your local SSH pub key (path configurable) to VirtualBox machines
- Run ansible playbooks
Everything should succeed in 8 minutes (tested on my local machine, AMD Ryzen 9 5900HS/32GB RAM/Win10/WSL2).
No errors nor warnings are expected.

# Access
## kubectl
Run `update_kubeconfig.sh` script to setup kubectl for your new cluster.
## Access nodes with SSH
```
ssh vagrant@ONE_OF_VM_IP_ADDRESSES_FROM_CONFIG -i PATH_TO_YOUR_SSH_PUB_KEY_FROM_CONFIG
```
You could also use hostnames for simplicity, init_local.sh script generates a file to append to your /etc/hosts:
```
<.vm_hostnames_to_append_to_etc_hosts tee -a /etc/hosts
```

# Testing
Spin up:
```
kubectl apply -f _smoke_test_deployment.yaml
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
(some evil but accurate response)
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
curl -sI ONE_OF_VM_IP_ADDRESSES_FROM_CONFIG:30007
HTTP/1.1 200 OK
Server: nginx/1.14.2
```
Print super secret secret:
```
$ kubectl exec deploy/nginx-deployment -- cat dupa/SUPER_SECRET
This is a good value
```

If any command returns something else, there is something wrong (no shit sherlock).
Also, Kubernetes the Hard Way contains additional smoke test instructions.

# Tear down
```
vagrant destroy
rm -fr .vagrant
```
To remove all files generated in scripts, including PKI, you also need to:
```
rm -fr .pki
rm .vagrant_hosts
rm .vm_hostnames_to_append_to_etc_hosts
```

# Troubleshooting
Cigarettes and reverse engineering
