wget -q --show-progress --https-only --timestamping \
    "https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kube-apiserver" \
    "https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kube-controller-manager" \
    "https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kube-scheduler" \
    "https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kubectl"
chmod +x kube-apiserver kube-controller-manager kube-scheduler kubectl
mv kube-apiserver kube-controller-manager kube-scheduler kubectl /usr/local/bin/
mkdir -p /var/lib/kubernetes/
mkdir -p /etc/kubernetes/config
mv ca.pem ca-key.pem api-server-key.pem api-server.pem service-account-key.pem service-account.pem /var/lib/kubernetes/
mv kube-controller-manager.kubeconfig /var/lib/kubernetes/
mv kube-scheduler.kubeconfig /var/lib/kubernetes/
