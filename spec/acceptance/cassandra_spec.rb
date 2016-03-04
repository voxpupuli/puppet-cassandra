require 'spec_helper_acceptance'

describe 'cassandra class' do
  cassandra_install_pp = <<-EOS
    if $::osfamily == 'RedHat' and $::operatingsystemmajrelease == 7 {
        $service_systemd = true
    } elsif $::operatingsystem == 'Debian' and $::operatingsystemmajrelease == 8 {
        $service_systemd = true
    } else {
        $service_systemd = false
    }

    if $::osfamily == 'RedHat' {
        $cassandra_optutils_package = 'cassandra20-tools'
        $cassandra_package = 'cassandra20'
        $version = '2.0.17-1'
    } else {
        $cassandra_optutils_package = 'cassandra-tools'
        $cassandra_package = 'cassandra'
        $version = '2.0.17'
    }

    class { 'cassandra::java': } ->
    class { 'cassandra::datastax_repo': } ->
    file { '/var/lib/cassandra':
      ensure => directory,
    } ->
    file { '/var/lib/cassandra/commitlog':
      ensure => directory,
    } ->
    file { '/var/lib/cassandra/caches':
      ensure => directory,
    } ->
    file { [ '/var/lib/cassandra/data' ]:
      ensure => directory,
    } ->
    class { 'cassandra':
      cassandra_9822              => true,
      cassandra_yaml_tmpl         => 'cassandra/cassandra20.yaml.erb',
      commitlog_directory_mode    => '0770',
      data_file_directories_mode  => '0770',
      package_ensure              => $version,
      package_name                => $cassandra_package,
      saved_caches_directory_mode => '0770',
      service_systemd             => $service_systemd
    }

    class { '::cassandra::datastax_agent':
      service_systemd => $service_systemd,
      require         => Class['cassandra']
    }

    class { '::cassandra::opscenter::pycrypto':
      manage_epel => true,
      before      => Class['::cassandra::opscenter']
    }

    class { '::cassandra::opscenter':
      config_purge => true,
      require      => Class['cassandra']
    }

    cassandra::opscenter::cluster_name { 'Cluster1':
      cassandra_seed_hosts => 'host1,host2',
    }
  EOS

  describe '########### Cassandra 2.0 installation.' do
    it 'should work with no errors' do
      apply_manifest(cassandra_install_pp, catch_failures: true)
    end
    it 'check code is idempotent' do
      expect(apply_manifest(cassandra_install_pp,
                            catch_failures: true).exit_code).to be_zero
    end
  end

  firewall_config_pp = <<-EOS
    class { 'cassandra':
      cassandra_9822              => true,
      commitlog_directory_mode    => '0770',
      data_file_directories_mode  => '0770',
      saved_caches_directory_mode => '0770',
    }

    include '::cassandra::optutils'
    include '::cassandra::datastax_agent'
    include '::cassandra::opscenter'
    include '::cassandra::opscenter::pycrypto'

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

  cassandra_uninstall20_pp = <<-EOS
    if $::osfamily == 'RedHat' {
        $cassandra_optutils_package = 'cassandra20-tools'
        $cassandra_package = 'cassandra20'
    } else {
        $cassandra_optutils_package = 'cassandra-tools'
        $cassandra_package = 'cassandra'
    }

    package { [$cassandra_optutils_package, $cassandra_package ]:
      ensure => absent
    }
  EOS

  describe '########### Uninstall Cassandra 2.0.' do
    it 'should work with no errors' do
      apply_manifest(cassandra_uninstall20_pp, catch_failures: true)
    end
  end

  cassandra_upgrade21_pp = <<-EOS
    if $::osfamily == 'RedHat' and $::operatingsystemmajrelease == 7 {
        $service_systemd = true
    } elsif $::operatingsystem == 'Debian' and $::operatingsystemmajrelease == 8 {
        $service_systemd = true
    } else {
        $service_systemd = false
    }

    if $::osfamily == 'RedHat' {
        $cassandra_optutils_package = 'cassandra21-tools'
        $cassandra_package = 'cassandra21'
        $version = '2.1.13-1'
    } else {
        $cassandra_optutils_package = 'cassandra-tools'
        $cassandra_package = 'cassandra'
        $version = '2.1.13'
    }

    class { 'cassandra':
      cassandra_9822              => true,
      #cassandra_yaml_tmpl         => 'cassandra/cassandra.yaml.erb',
      commitlog_directory_mode    => '0770',
      data_file_directories_mode  => '0770',
      listen_interface            => 'lo',
      package_ensure              => $version,
      package_name                => $cassandra_package,
      rpc_interface               => 'lo',
      saved_caches_directory_mode => '0770',
      service_systemd             => $service_systemd
    }
  EOS

  describe '########### Cassandra 2.1 installation.' do
    it 'should work with no errors' do
      apply_manifest(cassandra_upgrade21_pp, catch_failures: true)
    end
    it 'check code is idempotent' do
      expect(apply_manifest(cassandra_upgrade21_pp,
                            catch_failures: true).exit_code).to be_zero
    end
  end
end
