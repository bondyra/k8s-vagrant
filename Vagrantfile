require 'yaml'

settings = YAML.load_file('config.yml')

Vagrant.configure("2") do |config|
  # These two scripts can be run also before running `vagrant up` - up to you
  config.trigger.before [:up, :provision] do |trigger|
    trigger.info = "Initializing local files"
    trigger.run = {inline: "bash ./init_local.sh"}
  end
  config.trigger.before [:up, :provision] do |trigger|
    trigger.info = "Initializing PKI"
    trigger.run = {inline: "bash ./init_pki.sh"}
  end
  config.vm.synced_folder '.', '/vagrant', disabled: true
  config.vm.box = settings['vagrant']['vm_box']

  # create masters
  master_settings_list = settings['vms'].select{|s| s["type"] == "master"}
  create_vms_and_provision_with_ansible(config, settings, master_settings_list, "masters_playbook.yml", "masters")

  # create proxy
  # only first "proxy" vm is taken into account. there should be always only one, but trying to do it idiot proof
  proxy_settings = settings['vms'].select{|s| s["type"] == "proxy"}[0]
  create_and_setup_vm(config, settings, proxy_settings, "proxy_playbook.yml", "proxies")

  # create workers
  worker_settings_list = settings['vms'].select{|s| s["type"] == "worker"}
  create_vms_and_provision_with_ansible(config, settings, worker_settings_list, "workers_playbook.yml", "workers")
end

def create_vms_and_provision_with_ansible(config, settings, vm_settings_list, ansible_playbook, ansible_hosts)
  vm_settings_list.each_with_index do |vm_settings, index|
    if index < vm_settings_list.size - 1
      create_and_setup_vm(config, settings, vm_settings, nil, nil)
    else
      # playbooks must be run for all hosts in group at once, so we need to run ansible only at the end
      create_and_setup_vm(config, settings, vm_settings, ansible_playbook, ansible_hosts)
    end
  end
end

def create_and_setup_vm(config, settings, vm_settings, ansible_playbook_to_run, ansible_hosts)
  config.vm.define vm_settings["hostname"] do |machine|
    machine.vm.hostname = vm_settings["hostname"]
    machine.vm.network "private_network", ip: vm_settings["ip_address"]
    machine.vm.provider "virtualbox" do |vb|
        vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    end
    machine.vm.provision "file", source: "#{settings['local']['ssh_pub_key_path']}", destination: "~/.ssh/id_rsa.pub"
    if ansible_playbook_to_run != nil
      machine.vm.provision "ansible" do |ansible|
        ansible.limit = ansible_hosts
        ansible.playbook = ansible_playbook_to_run
        ansible.inventory_path = ".vagrant_hosts"
        ansible.host_key_checking = false
      end
    end
  end
end
