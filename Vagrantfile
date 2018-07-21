# -*- mode: ruby -*-
# vi: set ft=ruby :

# Nodes:
#  master  172.20.25.10
#  node    172.20.25.11

nodes = {
    'master11' => [1, 10, 'large_disk'],
    'node11' => [1, 11, 'large_disk']
}

Vagrant.configure("2") do |config|

  # clean up files on the host after the guest is destroyed
  #config.trigger.after :destroy do
  #  run "rm -f ./tmp/*"
  #end

  # Defaults (VirtualBox)
  config.vm.box = "centos/7"
  config.vm.synced_folder ".", "/vagrant"

  nodes.each do |prefix, (count, ip_end, another_disk_name)|
    hostname = "%s" % [prefix]
    another_disk = "./tmp/#{another_disk_name}_#{prefix}.vdi"

    config.ssh.username = "vagrant"
    # config.ssh.password = "vagrant"
    # config.ssh.insert_key = false
    # config.ssh.private_key_path = "./keys/private"
    config.vm.provision "file", source: "./keys/public", destination: "/tmp/authorized_keys"
    config.vm.provision "file", source: "./keys/private", destination: "/tmp/private"
    config.vm.provision "file", source: "./ansible/inventory", destination: "/tmp/hosts"

    config.vm.provision :shell, :privileged => true, inline: <<-EOF
      mkdir -p /root/.ssh && \
      mv /tmp/authorized_keys /root/.ssh/authorized_keys && \
      chmod 0600 /root/.ssh/authorized_keys && \
      chown root:root /root/.ssh/authorized_keys && \
      cp /tmp/private /root/.ssh/id_rsa && \
      chmod 0600 /root/.ssh/id_rsa && \
      chown root:root /root/.ssh/id_rsa && \
      cp /tmp/hosts /root/hosts && \
      chown root:root /root/hosts
    EOF

    config.vm.provision :shell, :privileged => true, path: "./scripts/prepare_common.sh"
    if prefix == "master"
      config.vm.provision :shell, :privileged => true, path: "./scripts/prepare_master.sh"
    else
      config.vm.provision :shell, :privileged => true, path: "./scripts/prepare_node.sh"
    end

    config.vm.define "#{hostname}" do |box|
      box.vm.hostname = "#{hostname}.nip.io"
      box.vm.network :private_network, ip: "172.20.25.#{ip_end}", :netmask => "255.255.255.0"

      box.vm.provider :virtualbox do |vbox|
        vbox.name = "#{hostname}"
        vbox.gui = false
        # Defaults
        vbox.linked_clone = true if Vagrant::VERSION =~ /^1.8/
        vbox.customize ["modifyvm", :id, "--memory", 4096]
        vbox.customize ["modifyvm", :id, "--cpus", 2]
        vbox.customize ["modifyvm", :id, "--nicpromisc2", "allow-all"]

        unless File.exist?(another_disk)
          vbox.customize ['createhd', '--filename', another_disk, '--size', 10 * 1024]
        end
        vbox.customize ['storageattach', :id, '--storagectl', 'IDE', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', another_disk]
      end
    end
  end
end