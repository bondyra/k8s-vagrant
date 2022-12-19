apt-get update
apt-get -y install socat conntrack ipset
swapoff -a
wget -q --show-progress --https-only --timestamping \
    https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.21.0/crictl-v1.21.0-linux-amd64.tar.gz \
    https://github.com/opencontainers/runc/releases/download/v1.0.0-rc93/runc.amd64 \
    https://github.com/containernetworking/plugins/releases/download/v0.9.1/cni-plugins-linux-amd64-v0.9.1.tgz \
    https://github.com/containerd/containerd/releases/download/v1.4.4/containerd-1.4.4-linux-amd64.tar.gz \
    https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kubectl \
    https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kube-proxy \
    https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kubelet
mkdir -p \
    /etc/cni/net.d \
    /opt/cni/bin \
    /var/lib/kubelet \
    /var/lib/kube-proxy \
    /var/lib/kubernetes \
    /var/run/kubernetes
mkdir containerd
tar -xvf crictl-v1.21.0-linux-amd64.tar.gz
tar -xvf containerd-1.4.4-linux-amd64.tar.gz -C containerd
tar -xvf cni-plugins-linux-amd64-v0.9.1.tgz -C /opt/cni/bin/
mv runc.amd64 runc
chmod +x crictl kubectl kube-proxy kubelet runc 
mv crictl kubectl kube-proxy kubelet runc /usr/local/bin/
mv containerd/bin/* /bin/
mkdir -p /etc/containerd/
mv cert-key.pem cert.pem /var/lib/kubelet/
mv worker.kubeconfig /var/lib/kubelet/kubeconfig
mv ca.pem /var/lib/kubernetes/
mv kube-proxy.kubeconfig /var/lib/kube-proxy/kubeconfig
modprobe br_netfilter  # necessary kernel module
