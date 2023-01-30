# !/bin/bash
config_file="config.yml"

# vagrant specific ansible connection config
cat <<EOF
[all:vars]
ansible_connection=ssh
ansible_user=vagrant
ansible_ssh_pass=vagrant

EOF

readarray workers < <(yq eval -o=j -I=0  '.workers[]' $config_file)
echo "[workers]"
for worker in "${workers[@]}"; do
    hostname=$(printf $worker | jq -r '.hostname')
    ip_address=$(printf $worker | jq -r '.ip_address')
    echo "$hostname ansible_host=$ip_address"
done

echo "[master]"
hostname=$(yq -r '.master.hostname' $config_file)
ip_address=$(yq -r '.master.ip_address' $config_file)
echo "$hostname ansible_host=$ip_address"
