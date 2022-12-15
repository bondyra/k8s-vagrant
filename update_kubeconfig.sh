config_file="config.json"
kubeconfig_context=$(jq -r '.kubeconfig_context' $config_file)
assets_dir=$(jq -r '.assets_dir' $config_file)
kubernetes_public_address=$(jq -r '.proxy.ip_address' $config_file)

kubectl config set-cluster $kubeconfig_context \
--certificate-authority=$assets_dir/ca.pem \
--embed-certs=true \
--server=https://$kubernetes_public_address:6443

kubectl config set-credentials $kubeconfig_context-user \
--client-certificate=$assets_dir/admin.pem \
--client-key=$assets_dir/admin-key.pem

kubectl config set-context $kubeconfig_context \
--cluster=$kubeconfig_context \
--user=$kubeconfig_context-user
