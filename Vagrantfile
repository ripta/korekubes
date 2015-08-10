# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "korekube-test"
  config.vm.box_url = "packer_vmware-iso_vmware.box"

  if Vagrant.has_plugin?("vagrant-vbguest")
    config.vbguest.auto_update = false
  end

  # config.vm.box_check_update = false
  # config.vm.network "forwarded_port", guest: 80, host: 8080
  # config.vm.network "private_network", ip: "192.168.33.10"
  config.vm.network :private_network, ip: '172.17.8.101'

  # config.vm.network "public_network"

  # config.vm.synced_folder "../data", "/vagrant_data"

  # config.push.define "atlas" do |push|
  #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"
  # end

  config.ssh.private_key_path = 'keys/coreos'

  config.vm.provision :file, source: 'cloud-configs/user-data.yaml', destination: '/tmp/user-data'
  config.vm.provision :shell, inline: 'mv /tmp/user-data /var/lib/coreos-install/', privileged: true

end
