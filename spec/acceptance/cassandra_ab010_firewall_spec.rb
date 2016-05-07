require 'spec_helper_acceptance'

describe 'cassandra class' do
  firewall_config_pp = <<-EOS
    if $::osfamily == 'RedHat' {
      $cassandra_package = 'cassandra20'
      $version = '2.0.17-1'
    } else {
      $cassandra_package = 'cassandra'
      $version = '2.0.17'
    }

    class { 'cassandra':
      authenticator               => 'PasswordAuthenticator',
      cassandra_9822              => true,
      cassandra_yaml_tmpl         => 'cassandra/cassandra20.yaml.erb',
      commitlog_directory_mode    => '0770',
      data_file_directories_mode  => '0770',
      package_ensure              => $version,
      package_name                => $cassandra_package,
      saved_caches_directory_mode => '0770',
    }

    include '::cassandra::datastax_agent'
    include '::cassandra::opscenter'

    # This really sucks but Docker, CentOS 6 and iptables don't play nicely
    # together.  Therefore we can't test the firewall on this platform :-(
    if $::operatingsystem != CentOS and $::operatingsystemmajrelease != 6 {
      include '::cassandra::firewall_ports'
    }
  EOS

  describe '########### Firewall configuration.' do
    it 'should work with no errors' do
      apply_manifest(firewall_config_pp, catch_failures: true)
    end
  end

  describe service('cassandra') do
    it { is_expected.to be_running }
    it { is_expected.to be_enabled }
  end

  describe service('datastax-agent') do
    it { is_expected.to be_running }
    it { is_expected.to be_enabled }
  end

  describe service('opscenterd') do
    it { is_expected.to be_running }
    it { is_expected.to be_enabled }
  end
end
