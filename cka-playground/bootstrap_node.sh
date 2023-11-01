systemctl disable --now ufw >/dev/null 2>&1

modprobe br_netfilter
cat >>/etc/modules-load.d/containerd.conf<<EOF
overlay
br_netfilter
EOF
modprobe overlay
modprobe br_netfilter

sed -i '/swap/d' /etc/fstab
swapoff -a

cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
EOF
sysctl --system >/dev/null 2>&1
echo "net.ipv4.ip_forward = 1" | tee -a /etc/sysctl.conf
sysctl -p

# mounting cgroup as it is not done for some reason, problem seems to be OS specific - could be obsolete on nodes other than ubuntu 22.04
mkdir /sys/fs/cgroup/systemd
mount -t cgroup -o none,name=systemd cgroup /sys/fs/cgroup/systemd

# Install k8s CLIs
apt-get update
apt-get install -y apt-transport-https ca-certificates curl
mkdir -p /etc/apt/keyrings
wget -O /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://dl.k8s.io/apt/doc/apt-key.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install -y kubelet=1.25.5-00 kubeadm=1.25.5-00 kubectl=1.25.5-00  # deliberately set to outdated versions to excercise cluster upgrades
apt-mark hold kubelet kubeadm kubectl

# runc
apt-get install -y libseccomp-dev
wget https://github.com/opencontainers/runc/releases/download/v1.1.4/runc.amd64
install -m 755 runc.amd64 /usr/local/sbin/runc

# containerd
wget https://github.com/containerd/containerd/releases/download/v1.6.14/containerd-1.6.14-linux-amd64.tar.gz
tar Cxzvf /usr/local containerd-1.6.14-linux-amd64.tar.gz
mkdir -p /usr/local/lib/systemd/system
wget -O /usr/local/lib/systemd/system/containerd.service https://raw.githubusercontent.com/containerd/containerd/main/containerd.service
mkdir -p /etc/containerd

cat > /etc/containerd/config.toml <<EOF
disabled_plugins = []
imports = []
root = "/var/lib/containerd"
state = "/run/containerd"
version = 2
[grpc]
  address = "/run/containerd/containerd.sock"
[plugins]
  [plugins."io.containerd.grpc.v1.cri"]
    systemd_cgroup = true
    sandbox_image = "registry.k8s.io/pause:3.2"
    [plugins."io.containerd.grpc.v1.cri".cni]
      bin_dir = "/opt/cni/bin"
      conf_dir = "/etc/cni/net.d"
    [plugins."io.containerd.grpc.v1.cri".containerd]
      default_runtime_name = "runc"
      [plugins."io.containerd.grpc.v1.cri".containerd.runtimes]
        [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
          runtime_type = "io.containerd.runtime.v1.linux"
          [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
            SystemdCgroup = true
EOF
systemctl restart containerd
systemctl enable containerd >/dev/null 2>&1
