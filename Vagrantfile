# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "trusty-cloud"
  config.vm.box_url = "https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"
  config.vm.network "private_network", type: "dhcp"

  config.vm.hostname = "basesystem.local"

  config.vm.provider "virtualbox" do |v|
    v.name = config.vm.hostname
    # ref: http://www.virtualbox.org/manual/ch08.html
    v.customize ["modifyvm", :id, "--cpuexecutioncap", "78"]
    v.customize ["modifyvm", :id, "--memory", "4072"]
  end

  # ref: http://docs.vagrantup.com/v2/provisioning/salt.html
  config.vm.synced_folder "salt/states",  "/srv/salt"
  config.vm.synced_folder "basesystem",   "/srv/salt/basesystem"
  config.vm.provision :salt do |c|
    c.minion_config = "salt/minion.conf"
    c.run_highstate = false
    c.verbose = true
  end
end
