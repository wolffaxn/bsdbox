# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.require_version ">= 1.7.2"

BOXNAME = "bsdbox"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # FreeBSD
  config.vm.guest = :freebsd
  config.vm.box = "freebsd-10.1-amd64"
  config.vm.box_url = "http://<hostname>/freebsd-10.1-amd64.box"

  # time in seconds that Vagrant will wait for the machine to boot
  config.vm.boot_timeout = 300

  # disable automatic box update checking
  config.vm.box_check_update = false

  # the hostname the machine should have
  config.vm.hostname = "#{BOXNAME}.localdomain"

  # NFS requires a host-only network to be created
  config.vm.network :private_network, ip: "192.168.2.10"

  # enable NFS for sharing the host machine into the vagrant VM
  config.vm.synced_folder ".", "/usr/home/vagrant", id: "vagrant-root", :nfs => true, :mount_options => ['nolock,vers=3,udp']

  config.vm.provider :virtualbox do |vb|
    vb.name = BOXNAME

    vb.customize ["modifyvm", :id, "--hwvirtex", "on"]
    vb.customize ["modifyvm", :id, "--cpus", "2"]
    vb.customize ["modifyvm", :id, "--memory", "2048"]
    vb.customize ["modifyvm", :id, "--audio", "none"]
    vb.customize ["modifyvm", :id, "--nictype1", "virtio"]
    vb.customize ["modifyvm", :id, "--nictype2", "virtio"]
  end

  # cache downloaded files
  if Vagrant.has_plugin?('vagrant-cachier')
    config.cache.scope = :machine
  end

  if Vagrant.has_plugin?('vagrant-hostsupdater')
    config.hostsupdater.aliases = node['aliases']
  end

  if Vagrant.has_plugin?('vagrant-vbguest')
    config.vbguest.auto_update = false
  end
end
