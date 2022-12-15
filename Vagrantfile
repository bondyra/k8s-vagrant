require 'json'

file = File.read('config.json')
settings = JSON.parse(file)

Vagrant.configure("2") do |config|
  config.trigger.before [:up, :provision] do |trigger|
    trigger.info = "Generating local assets..."
    trigger.run = {inline: "bash ./generate_assets.sh"}
  end

  config.vm.synced_folder '.', '/vagrant', disabled: true
  config.vm.box = settings['vm_box']

  create_vms_and_provision_with_ansible(config, settings, "masters", "masters_playbook.yml", "masters")

  create_and_setup_vm(config, settings, settings["proxy"], "proxy_playbook.yml", "proxy")

  create_vms_and_provision_with_ansible(config, settings, "workers", "workers_playbook.yml", "workers")
end

def create_vms_and_provision_with_ansible(config, settings, group_name, playbook, hosts)
  group_settings = settings[group_name]
  group_settings.each_with_index do |vm_settings, index|
    if index < group_settings.size - 1
      create_and_setup_vm(config, settings, vm_settings, nil, nil)
    else
      # playbooks must be run for all hosts in group at once, so we need to run ansible only at the end
      create_and_setup_vm(config, settings, vm_settings, playbook, hosts)
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
    machine.vm.provision "file", source: "#{settings['ssh_pub_key_path']}", destination: "~/.ssh/id_rsa.pub"
    if ansible_playbook_to_run != nil
      machine.vm.provision "ansible" do |ansible|
        ansible.limit = ansible_hosts
        ansible.playbook = ansible_playbook_to_run
        ansible.inventory_path = "#{settings['assets_dir']}/#{settings['ansible_inventory_file']}"
        ansible.host_key_checking = false
      end
    end
  end
end
