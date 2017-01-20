# TODO: Find out why cassandra::params not working with vagrant and CentOS 6.2
# TODO: Find out why cassandra::params not working with vagrant and CentOS 7.0
# TODO: Find out why cassandra::params not working with vagrant and Ubuntu 12.04.
# TODO: Have vagrant dynamically discover Puppet modules from metadata.json.
Vagrant.configure('2') do |config|
  # config.vm.box = 'puppetlabs/centos-6.6-64-puppet'
  # config.vm.box = 'puppetlabs/centos-7.0-64-puppet'
  config.vm.box = 'puppetlabs/debian-7.8-64-puppet'
  # config.vm.box = 'puppetlabs/debian-8.2-64-puppet'
  # config.vm.box = "puppetlabs/ubuntu-12.04-64-puppet"
  # config.vm.box = "puppetlabs/ubuntu-14.04-64-puppet"
  # config.vm.box = "puppetlabs/ubuntu-16.04-64-puppet"

  config.vm.provider 'virtualbox' do |vm|
    vm.memory = 2048
    vm.cpus = 2
  end

  puppet_environment = 'vagrant'
  puppet_environment_path_on_guest = "/etc/puppetlabs/code/environments/#{puppet_environment}"
  module_path_on_guest = "#{puppet_environment_path_on_guest}/modules"

  config.vm.synced_folder './vagrant',
                          '/etc/puppetlabs/code/environments/vagrant'
  config.vm.synced_folder '.',
                          '/etc/puppetlabs/code/environments/vagrant/modules/cassandra'
  config.vm.synced_folder './spec/acceptance/hieradata',
                          '/etc/puppetlabs/code/environments/vagrant/hieradata'

  config.vm.provision :shell, inline: "test -d #{module_path_on_guest}/ || mkdir #{puppet_environment_path_on_guest}"
  config.vm.provision :shell, inline: "test -d #{module_path_on_guest}/apt || puppet module install puppetlabs-apt --environment=#{puppet_environment}"
  config.vm.provision :shell, inline: "test -d #{module_path_on_guest}/firewall || puppet module install puppetlabs-firewall --environment=#{puppet_environment}"
  config.vm.provision :shell, inline: "test -d #{module_path_on_guest}/inifile || puppet module install puppetlabs-inifile --environment=#{puppet_environment}"
  config.vm.provision :shell, inline: "test -d #{module_path_on_guest}/stdlib || puppet module install puppetlabs-stdlib --environment=#{puppet_environment}"

  config.vm.provision :puppet do |puppet|
    puppet.options = ENV['PUPPET_OPTS'].split(' ') if ENV.key?('PUPPET_OPTS') # See http://stackoverflow.com/a/27540417/224334
    puppet.options = '--verbose --debug' if ENV['PUPPET_VERBOSE']
    puppet.hiera_config_path = 'vagrant/hiera.yaml'
    puppet.environment = puppet_environment
    puppet.environment_path = './'
    puppet.manifests_path   = "#{puppet_environment}/manifests"
    puppet.manifest_file = 'site.pp'
    puppet.facter = {
      project_name: 'ENGLISH NAME Of PROJECT', # EDIT THIS LINE
    }
  end

  config.vm.network :forwarded_port, guest: 22, host: 2223, auto_correct: true, id: 'ssh'
  config.vm.network :forwarded_port, guest: 3000, host: 3000
end
