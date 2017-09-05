# -*- mode: ruby -*-
# vi: set ft=ruby :


Vagrant.configure("2") do |config|
  (1..3.to_i).each do |i|
    if i == 1
      name = "master"
      count = ''
    else
      name = "node"
      count = i - 1
    end

    config.vm.define  "#{name}#{count}" do |node|
        node.vm.box = "centos/7"
        node.vm.hostname = "#{name}#{count}"

        node.vm.network :private_network,
          ip: "10.14.0.1#{i}",
          libvirt__network_name: "kube-pub",
          libvirt__dhcp_enabled: false,
          libvirt__forward_mode: "nat",
          libvirt__host_ip: "10.14.0.1",
          autostart: true
        if i != 1
          node.vm.network :private_network,
            ip: "10.230.0.1#{i}",
            libvirt__network_name: "kube-prv",
            libvirt__dhcp_enabled: false,
            libvirt__forward_mode: "nat",
            libvirt__host_ip: "10.230.0.1",
            autostart: true
        end
        node.vm.provider :libvirt do |domain|
          domain.memory = 4096
          domain.cpus = 2
        end
        node.vm.provider :virtualbox do |domain|
          domain.memory = 1024
          domain.cpus = 2
        end

        node.vm.provision :shell, inline: "sed 's/127\.0\.0\.1.*#{name}.*/10\.14\.0\.1#{i} #{name}#{count}/' -i /etc/hosts"
        node.vm.provision "shell", path: "files/install.sh"
    end
  end
end
