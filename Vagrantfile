# -*- mode: ruby -*-
# vi: set ft=ruby :

# To use this, do the following:
#
#   bundle exec rake generate_puppetfile
#   cd vagrant/environments/production
#   librarian-puppet install --clean --verbose
#   cd ../../..

require 'json'

VAGRANTFILE_API_VERSION = '2'.freeze

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.hostname = 'node0'
  # config.vm.box = 'puppetlabs/centos-6.6-64-nocm'
  # config.vm.box = 'puppetlabs/centos-7.0-64-nocm'
  config.vm.box = 'puppetlabs/debian-8.2-64-puppet'
  # config.vm.box = 'puppetlabs/ubuntu-14.04-64-nocm'
  config.vm.synced_folder '.', '/etc/puppetlabs/code/environments/production/modules/cassandra'
  config.vm.network 'forwarded_port', guest: 8888, host: 8888
  config.vm.provider 'virtualbox' do |vb|
    vb.customize ['modifyvm', :id, '--memory', '2048']
  end

  config.vm.provision :puppet do |puppet|
    puppet.environment = 'production'
    puppet.environment_path  = 'vagrant/environments'
    # puppet.module_path = './vagrant/environments/production/modules'
    # puppet.options = "--debug --trace --verbose"
    puppet.hiera_config_path = 'vagrant/hiera.yaml'
  end
end
