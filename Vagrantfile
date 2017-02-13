# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.provision :shell, inline: <<-SHELL
    sudo add-apt-repository ppa:brightbox/ruby-ng -y
    sudo apt-get update > /dev/null
    sudo apt-get install git mc vim ruby2.3 ruby2.3-dev -y
    sudo gem install bundler
  SHELL
end
