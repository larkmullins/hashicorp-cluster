# -*- mode: ruby -*-
# vi: set ft=ruby :

WORKSPACE     = ENV['WORKSPACE'] || '.'
NUM_SERVERS   = ENV['NUM_SERVERS'] || 1
NUM_CLIENTS   = ENV['NUM_CLIENTS'] || 1
SERVER_PREFIX = ENV['SERVER_PREFIX'] || 'server'
CLIENT_PREFIX = ENV['CLIENT_PREFIX'] || 'client'
VM_GUI        = ENV['VM_GUI'] || false
VM_MEM        = ENV['VM_MEM'] || 1024
VM_CPU        = ENV['VM_CPU'] || 1
VM_CAP        = ENV['VM_CAP'] || 100

# install required plugins
required_plugins = %w( vagrant-ignition vagrant-triggers )
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
  config.vm.synced_folder ".", "/vagrant"

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
      end

      # set ip address for server
      ip = "172.17.8.#{i+100}"
      server.vm.network :private_network, ip: ip
      config.ignition.ip = ip

      # build conf files
      server.vm.provision "ansible" do |ansible|
        ansible.playbook       = "./configuration.yml"
        ansible.inventory_path = "./inventory.yml"
      end

      # provision consul container
      server.vm.provision "docker" do |consul|
        consul.build_image "/vagrant/docker/consul", args: "-t consul"
        consul.run "consul",
          args: "--name consul --privileged --net host \
                    -v /run/docker.sock:/run/docker.sock \
                    -v /tmp:/tmp \
                    -p 8300:8300 \
                    -p 8301:8301 \
                    -p 8302:8302 \
                    -p 8500:8500 \
                    -p 8600:8600 \
                    -p 8301:8301/udp \
                    -p 8302:8302/udp \
                    -p 8600:8600/udp"
      end

      # provision nomad container
      server.vm.provision "docker" do |nomad|
        nomad.build_image "/vagrant/docker/nomad", args: "-t nomad"
        nomad.run "nomad",
          args: "--name nomad --privileged --net host \
                  -v /run/docker.sock:/run/docker.sock \
                  -v /tmp:/tmp \
                  -p 4646:4646 \
                  -p 4647:4647 \
                  -p 4648:4648 \
                  -p 4648:4648/udp"
      end
    end
  end

  config.vm.define "toolbox" do |toolbox|
    toolbox.vm.box = "larkmullins/centos7-x86_64-minimal"
    toolbox.vm.hostname = "toolbox"
    toolbox.vm.synced_folder WORKSPACE, "/vagrant"
  end
end
