# -*- mode: ruby -*-
# vi: set ft=ruby :

NUM_SERVERS   = ENV['NUM_SERVERS'] || 1
NUM_CLIENTS   = ENV['NUM_CLIENTS'] || 1
SERVER_PREFIX = ENV['SERVER_PREFIX'] || 'server'
CLIENT_PREFIX = ENV['CLIENT_PREFIX'] || 'client'
VM_GUI        = ENV['VM_GUI'] || false
VM_MEM        = ENV['VM_MEM'] || 1024
VM_CPU        = ENV['VM_CPU'] || 1
VM_CAP        = ENV['VM_CAP'] || 100

# install required plugins
required_plugins = %w( vagrant-ignition )
required_plugins.each do |plugin|
  exec "vagrant plugin install #{plugin};vagrant #{ARGV.join(" ")}" unless Vagrant.has_plugin? plugin || ARGV[0] == 'plugin'
end

Vagrant.configure(2) do |config|
  # always use vagrant's insecure key
  config.ssh.insert_key = false

  # setup Virtualbox for CoreOS
  config.vm.provider :virtualbox do |vb|
    vb.check_guest_additions = false
    vb.functional_vboxsf     = false

    vb.customize ["modifyvm", :id, "--uart1", "0x3F8", "4"]

    # enable coreos ignition, this is how the key is added
    config.ignition.enabled = true
  end

  config.vm.box = "coreos-stable"
  config.vm.box_url = "https://stable.release.core-os.net/amd64-usr/current/coreos_production_vagrant.box"

  # setup servers
  (1..NUM_SERVERS).each do |i|
    config.vm.define vm_name = "%s-%02d" % [SERVER_PREFIX, i] do |server|
      # set hostname
      server.vm.hostname = vm_name

      # setup virtualbox for server
      server.vm.provider :virtualbox do |vb|
        vb.gui    = VM_GUI
        vb.memory = VM_MEM
        vb.cpus   = VM_CPU
        vb.customize ["modifyvm", :id, "--cpuexecutioncap", "#{VM_CAP}"]

        # configure ignition
        config.ignition.config_obj = vb
        config.ignition.hostname   = vm_name
        config.ignition.drive_name = "config" + i.to_s
        config.ignition.path       = "./config.ign"
      end

      # set ip address for server
      ip = "172.17.8.#{i+100}"
      server.vm.network :private_network, ip: ip
      config.ignition.ip = ip
    end
  end
end
