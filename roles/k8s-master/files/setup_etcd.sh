wget -q --show-progress --https-only --timestamping "https://github.com/etcd-io/etcd/releases/download/v3.4.15/etcd-v3.4.15-linux-amd64.tar.gz"
tar -xvf etcd-v3.4.15-linux-amd64.tar.gz
mv etcd-v3.4.15-linux-amd64/etcd* /usr/local/bin/
mkdir -p /etc/etcd /var/lib/etcd
chmod 700 /var/lib/etcd
cp ca.pem api-server-key.pem api-server.pem /etc/etcd/
