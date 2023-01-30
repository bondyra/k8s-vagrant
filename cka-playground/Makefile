.DEFAULT_GOAL := cluster
.PHONY: .vagrant_up .inventory .ansible .vagrant_destroy .remove_stuff

cluster: .vagrant_up .inventory .ansible .env
	echo "Cluster ready to use. Run 'source .env' to set KUBECONFIG to point to kubeconfig pulled from master."

destroy: .vagrant_destroy .remove_stuff

.vagrant_up:
	vagrant upss

.inventory:
	bash ./config_to_ansible_inventory.sh > .vagrant_hosts

.ansible:
	ansible-playbook -i .vagrant_hosts --extra-vars @config.yml playbook.yml

.env:
	echo "export KUBECONFIG=${PWD}/this.kubeconfig" > .env

.vagrant_destroy:
	vagrant destroy

.remove_stuff:
	rm -f .vagrant_hosts
	rm -fr .vagrant
	rm -f *.kubeconfig
	rm -f .env
