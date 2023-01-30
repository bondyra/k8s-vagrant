# Requirements
- Linux (tested on Ubuntu 22.04 LTS on WSL2 Win10)
- VirtualBox (tested on 7.0.2 Windows)
- ansible (tested on version 2.13.5)
- vagrant (tested on version 2.3.2)
- yq (tested on version 4.30.5)
- jq (tested on version 1.6)

Idle cluster resource requirements formula: `2GB + number_of_workers * 1GB`, `2 CPU + number_of_workers * 1 CPU`
So 4 GB RAM and 4 CPUs for 2 worker setup.

# Configure
There shouldn't be any hardcoded elements in scripts, you can manage everything using single `config.yml` file. Config contains comments that explain how to use it.

# Run
```
make
```
This will do following things:
- Create VirtualBox machines
- Upload your local SSH pub key (path configurable) to VirtualBox machines
- Generate ansible inventory based on config
- Run ansible playbook that provisions the machines
- Setup .env file to source and print its usage

Everything should succeed in 10 minutes (tested on my local machine, AMD Ryzen 9 5900HS/32GB RAM/Win10/WSL2).
No errors nor warnings are expected.

# Access
## kubectl
Source the .env file that is created by `make`. This will set KUBECONFIG env var and let you use kubectl.
## Access nodes with SSH
```
ssh vagrant@ONE_OF_VM_IP_ADDRESSES_FROM_CONFIG -i PATH_TO_YOUR_SSH_PUB_KEY_FROM_CONFIG
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
(some reasonable but evil response)
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
make destroy
```

# Troubleshooting
Cigarettes and reverse engineering
