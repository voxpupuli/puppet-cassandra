require 'beaker-rspec'
require 'pry'

CASSANDRA2_UNSUPPORTED_PLATFORMS = ['16.04'].freeze

thr = Thread.new do
  loop do
    sleep 1
    `sudo pkill agetty`
  end
end

hosts.each do |host|
  case host.name
  when 'ubuntu1604'
    host.install_package('puppet')
  else
    install_puppet_on(host)
  end
end

RSpec.configure do |c|
  module_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install modules
    puppet_module_install(source: module_root, module_name: 'cassandra')
    hosts.each do |host|
      on host, puppet('module', 'install',
                      'puppetlabs-apt'), acceptable_exit_codes: [0, 1]
      on host, puppet('module', 'install',
                      'puppetlabs-firewall'), acceptable_exit_codes: [0, 1]
      on host, puppet('module', 'install',
                      'puppetlabs-inifile'), acceptable_exit_codes: [0, 1]
      on host, puppet('module', 'install',
                      'puppetlabs-stdlib'), acceptable_exit_codes: [0, 1]
      # Install hiera
      write_hiera_config_on(host,
                            [
                              'environments/%{environment}/data/fqdn/%{fqdn}',
                              'environments/%{environment}/data/osfamily/%{osfamily}/%{lsbdistcodename}',
                              'environments/%{environment}/data/osfamily/%{osfamily}/%{lsbmajdistrelease}',
                              'environments/%{environment}/data/osfamily/%{osfamily}/%{architecture}',
                              'environments/%{environment}/data/osfamily/%{osfamily}/common',
                              # 'environments/%{environment}/data/modules/%{cname}',
                              'environments/%{environment}/data/modules/%{caller_module_name}',
                              'environments/%{environment}/data/modules/%{module_name}',
                              'environments/%{environment}/data/common'
                            ])
      copy_hiera_data_to(host, './spec/acceptance/hieradata/')
    end
  end
end

thr.exit
