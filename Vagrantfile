# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

 config.vm.define "rpmbuild" do |rpmbuild|
   rpmbuild.ssh.insert_key = false
   rpmbuild.vm.box = "bento/centos-7.1"
   rpmbuild.vm.network :forwarded_port, guest: 80, host: 5667, auto_correct: true
   rpmbuild.vm.network "private_network", ip: "192.168.33.11"
   rpmbuild.vm.hostname = "rpmbuild"
   rpmbuild.vm.provision "shell", inline: <<-SHELL
      sudo yum install -y rpmdevtools rpmlint gcc git
   SHELL
 end  # Create a private network, which allows host-only access to the machine
 # using a specific IP.
 # config.vm.network "private_network", ip: "192.168.33.10"

 # Create a public network, which generally matched to bridged network.
 # Bridged networks make the machine appear as another physical device on
 # your network.
 # config.vm.network "public_network"

 # documentation for more information about their specific syntax and use.
 # config.vm.provision "shell", inline: <<-SHELL
 #   sudo apt-get update
 #   sudo apt-get install -y apache2
 # SHELL
end
