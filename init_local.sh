# !/bin/bash

# This script translates current config into two files to be used locally:
# - .vagrant_hosts - required ansible inventory file
# - .vm_hostnames_to_append_to_etc_hosts - which you can append to your /etc/hosts to later reference vms by names

config_file="config.yml"
ansible_inventory_file_name=".vagrant_hosts"
etc_hosts_to_append_file_name=".vm_hostnames_to_append_to_etc_hosts"

rm -f $ansible_inventory_file_name
rm -f $etc_hosts_to_append_file_name

# vagrant specific ansible connection config
cat >> $ansible_inventory_file_name <<EOF
[all:vars]
ansible_connection=ssh
ansible_user=vagrant
ansible_ssh_pass=vagrant

EOF

readarray workers < <(yq eval -o=j -I=0  '.vms[] | select (.type=="worker")' $config_file)
# WARNING: inventory group names are hardwired - during a rename, you must change names both here, in Vagrantfile and in playbooks
echo "[workers]" >> $ansible_inventory_file_name
for worker in "${workers[@]}"; do
    hostname=$(printf $worker | jq -r '.hostname')
    ip_address=$(printf $worker | jq -r '.ip_address')
    pod_cidr=$(printf $worker | jq -r '.pod_cidr')
    echo "$hostname ansible_host=$ip_address this_hostname=$hostname this_ip_address=$ip_address this_pod_cidr=$pod_cidr" >> $ansible_inventory_file_name
    echo "$ip_address $hostname" >> $etc_hosts_to_append_file_name
done

readarray masters < <(yq eval -o=j -I=0  '.vms[] | select (.type=="master")' $config_file)
echo "[masters]" >> $ansible_inventory_file_name
for master in "${masters[@]}"; do
    hostname=$(printf $master | jq -r '.hostname')
    ip_address=$(printf $master | jq -r '.ip_address')
    echo "$hostname ansible_host=$ip_address this_hostname=$hostname this_ip_address=$ip_address" >> $ansible_inventory_file_name
    echo "$ip_address $hostname" >> $etc_hosts_to_append_file_name
done

# there should be always only one, but trying to do it idiot proof
readarray proxies < <(yq eval -o=j -I=0  '.vms[] | select (.type=="proxy")' $config_file)
echo "[proxies]" >> $ansible_inventory_file_name
for proxy in "${proxies[@]}"; do
    hostname=$(printf $proxy | jq -r '.hostname')
    ip_address=$(printf $proxy | jq -r '.ip_address')
    echo "$hostname ansible_host=$ip_address this_hostname=$hostname this_ip_address=$ip_address" >> $ansible_inventory_file_name
    echo "$ip_address $hostname" >> $etc_hosts_to_append_file_name
done
