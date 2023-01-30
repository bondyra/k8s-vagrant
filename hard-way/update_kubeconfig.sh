# !/bin/bash

# This script allows you to seamlessly talk with newly provisioned cluster
# So it takes administrator cert & key from initialized PKI and updates your config
# WARNING: It overwrites everything that resides under configured kubeconfig context name, so use with caution

config_file="config.yml"
kubeconfig_context_name=$(yq -r '.local.kubeconfig_context_name' $config_file)
kubernetes_public_address=$(yq -r '[.vms[] | select(.type=="proxy")  | .ip_address][0]' $config_file)  # first "proxy" type vm. there should be always only one, but trying to do it idiot proof

kubectl config set-cluster $kubeconfig_context_name \
--certificate-authority=.pki/ca.pem \
--embed-certs=true \
--server=https://$kubernetes_public_address:6443

kubectl config set-credentials $kubeconfig_context_name \
--client-certificate=.pki/admin.pem \
--client-key=.pki/admin-key.pem

kubectl config set-context $kubeconfig_context_name \
--cluster=$kubeconfig_context_name \
--user=$kubeconfig_context_name
