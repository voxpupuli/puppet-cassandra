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
      $cassandra_package = 'cassandra20'
      $version = '2.0.17-1'
    } else {
      $cassandra_package = 'cassandra'
      $version = '2.0.17'

      exec { '/bin/chown root:root /etc/apt/sources.list.d/datastax.list':
        unless  => '/usr/bin/test -O /etc/apt/sources.list.d/datastax.list',
        require => Class['cassandra::opscenter']
      }
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
      config_purge    => true,
      service_systemd => $service_systemd,
      require         => Class['cassandra'],
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
    if $::osfamily == 'RedHat' {
      $cassandra_package = 'cassandra20'
      $version = '2.0.17-1'
    } else {
      $cassandra_package = 'cassandra'
      $version = '2.0.17'
    }

    class { 'cassandra':
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
      commitlog_directory_mode    => '0770',
      data_file_directories_mode  => '0770',
      listen_interface            => 'lo',
      package_ensure              => $version,
      package_name                => $cassandra_package,
      rpc_interface               => 'lo',
      saved_caches_directory_mode => '0770',
      service_systemd             => $service_systemd
    }

    class { 'cassandra::optutils':
      ensure       => $version,
      package_name => $cassandra_optutils_package,
      require      => Class['cassandra']
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

  describe service('cassandra') do
    it { is_expected.to be_running }
    it { is_expected.to be_enabled }
  end

  cassandra_uninstall21_pp = <<-EOS
    if $::osfamily == 'RedHat' {
        $cassandra_optutils_package = 'cassandra21-tools'
        $cassandra_package = 'cassandra21'
    } else {
        $cassandra_optutils_package = 'cassandra-tools'
        $cassandra_package = 'cassandra'
    }

    package { [$cassandra_optutils_package, $cassandra_package ]:
      ensure => absent
    }
  EOS

  describe '########### Uninstall Cassandra 2.1.' do
    it 'should work with no errors' do
      apply_manifest(cassandra_uninstall21_pp, catch_failures: true)
    end
  end

  cassandra_upgrade22_pp = <<-EOS
    if $::osfamily == 'RedHat' and $::operatingsystemmajrelease == 7 {
        $service_systemd = true
    } elsif $::operatingsystem == 'Debian' and $::operatingsystemmajrelease == 8 {
        $service_systemd = true
    } else {
        $service_systemd = false
    }

    if $::osfamily == 'RedHat' {
        $cassandra_optutils_package = 'cassandra22-tools'
        $cassandra_package = 'cassandra22'
        $version = '2.2.5-1'
    } else {
        $cassandra_optutils_package = 'cassandra-tools'
        $cassandra_package = 'cassandra'
        $version = '2.2.5'
    }

    class { 'cassandra':
      cassandra_9822              => true,
      commitlog_directory_mode    => '0770',
      data_file_directories_mode  => '0770',
      listen_interface            => 'lo',
      package_ensure              => $version,
      package_name                => $cassandra_package,
      rpc_interface               => 'lo',
      saved_caches_directory_mode => '0770',
      service_systemd             => $service_systemd
    }

    class { 'cassandra::optutils':
      package_ensure => $version,
      package_name   => $cassandra_optutils_package,
      require        => Class['cassandra']
    }
  EOS

  describe '########### Cassandra 2.2 installation.' do
    it 'should work with no errors' do
      apply_manifest(cassandra_upgrade22_pp, catch_failures: true)
    end
    it 'check code is idempotent' do
      expect(apply_manifest(cassandra_upgrade22_pp,
                            catch_failures: true).exit_code).to be_zero
    end
  end

  describe service('cassandra') do
    it { is_expected.to be_running }
    it { is_expected.to be_enabled }
  end

  schema_testing_create_pp = <<-EOS
    if $::osfamily == 'RedHat' and $::operatingsystemmajrelease == 7 {
        $service_systemd = true
    } elsif $::operatingsystem == 'Debian' and $::operatingsystemmajrelease == 8 {
        $service_systemd = true
    } else {
        $service_systemd = false
    }

    if $::osfamily == 'RedHat' {
        $cassandra_optutils_package = 'cassandra22-tools'
        $cassandra_package = 'cassandra22'
        $version = '2.2.5-1'
    } else {
        $cassandra_optutils_package = 'cassandra-tools'
        $cassandra_package = 'cassandra'
        $version = '2.2.5'
    }

    class { 'cassandra':
      cassandra_9822              => true,
      commitlog_directory_mode    => '0770',
      data_file_directories_mode  => '0770',
      listen_interface            => 'lo',
      package_ensure              => $version,
      package_name                => $cassandra_package,
      rpc_interface               => 'lo',
      saved_caches_directory_mode => '0770',
      service_systemd             => $service_systemd
    }

    $keyspaces = {
      'mykeyspace' => {
        ensure          => present,
        replication_map => {
          keyspace_class     => 'SimpleStrategy',
          replication_factor => 1,
        },
        durable_writes  => false,
      },
    }

    if $::operatingsystem != CentOS and $::operatingsystemmajrelease != 6 {
      class { 'cassandra::schema':
        indexes   => {
          'users_lname_idx' => {
             keyspace => 'mykeyspace',
             table    => 'users',
             keys     => 'lname',
          },
        },
        keyspaces => $keyspaces,
        tables    => {
          'users' => {
            'keyspace' => 'mykeyspace',
            'columns'       => {
              'userid'      => 'int',
              'fname'       => 'text',
              'lname'       => 'text',
              'PRIMARY KEY' => '(userid)',
            },
          },
        },
      }
    }
  EOS

  describe '########### Schema create.' do
    it 'should work with no errors' do
      apply_manifest(schema_testing_create_pp, catch_failures: true)
    end
    it 'check code is idempotent' do
      expect(apply_manifest(schema_testing_create_pp,
                            catch_failures: true).exit_code).to be_zero
    end
  end

  schema_testing_drop__index_and_cql_type_pp = <<-EOS
    if $::osfamily == 'RedHat' and $::operatingsystemmajrelease == 7 {
        $service_systemd = true
    } elsif $::operatingsystem == 'Debian' and $::operatingsystemmajrelease == 8 {
        $service_systemd = true
    } else {
        $service_systemd = false
    }

    if $::osfamily == 'RedHat' {
        $cassandra_optutils_package = 'cassandra22-tools'
        $cassandra_package = 'cassandra22'
        $version = '2.2.5-1'
    } else {
        $cassandra_optutils_package = 'cassandra-tools'
        $cassandra_package = 'cassandra'
        $version = '2.2.5'
    }

    class { 'cassandra':
      cassandra_9822              => true,
      commitlog_directory_mode    => '0770',
      data_file_directories_mode  => '0770',
      listen_interface            => 'lo',
      package_ensure              => $version,
      package_name                => $cassandra_package,
      rpc_interface               => 'lo',
      saved_caches_directory_mode => '0770',
      service_systemd             => $service_systemd
    }

    $cql_types = {
      'address' => {
        'keyspace' => 'Excalibur',
        'ensure'   => 'absent'
      }
    }

    if $::operatingsystem != CentOS and $::operatingsystemmajrelease != 6 {
      class { 'cassandra::schema':
        indexes   => {
          'users_emails_idx' => {
             ensure   => absent,
             keyspace => 'Excalibur',
             table    => 'users',
          },
        },
        cql_types => $cql_types
      }
    }
  EOS

  describe '########### Schema drop (Indexes & Types).' do
    it 'should work with no errors' do
      apply_manifest(schema_testing_drop__index_and_cql_type_pp,
                     catch_failures: true)
    end
    it 'check code is idempotent' do
      expect(apply_manifest(schema_testing_drop__index_and_cql_type_pp,
                            catch_failures: true).exit_code).to be_zero
    end
  end

  schema_testing_drop_table_pp = <<-EOS
    if $::osfamily == 'RedHat' and $::operatingsystemmajrelease == 7 {
        $service_systemd = true
    } elsif $::operatingsystem == 'Debian' and $::operatingsystemmajrelease == 8 {
        $service_systemd = true
    } else {
        $service_systemd = false
    }

    if $::osfamily == 'RedHat' {
        $cassandra_optutils_package = 'cassandra22-tools'
        $cassandra_package = 'cassandra22'
        $version = '2.2.5-1'
    } else {
        $cassandra_optutils_package = 'cassandra-tools'
        $cassandra_package = 'cassandra'
        $version = '2.2.5'
    }

    class { 'cassandra':
      cassandra_9822              => true,
      commitlog_directory_mode    => '0770',
      data_file_directories_mode  => '0770',
      listen_interface            => 'lo',
      package_ensure              => $version,
      package_name                => $cassandra_package,
      rpc_interface               => 'lo',
      saved_caches_directory_mode => '0770',
      service_systemd             => $service_systemd
    }

    if $::operatingsystem != CentOS and $::operatingsystemmajrelease != 6 {
      class { 'cassandra::schema':
        tables   => {
          'users' => {
             ensure   => absent,
             keyspace => 'Excalibur',
          },
        },
      }
    }
  EOS

  describe '########### Schema drop (Tables).' do
    it 'should work with no errors' do
      apply_manifest(schema_testing_drop_table_pp, catch_failures: true)
    end
    it 'check code is idempotent' do
      expect(apply_manifest(schema_testing_drop_table_pp,
                            catch_failures: true).exit_code).to be_zero
    end
  end

  schema_testing_drop_pp = <<-EOS
    if $::osfamily == 'RedHat' and $::operatingsystemmajrelease == 7 {
        $service_systemd = true
    } elsif $::operatingsystem == 'Debian' and $::operatingsystemmajrelease == 8 {
        $service_systemd = true
    } else {
        $service_systemd = false
    }

    if $::osfamily == 'RedHat' {
        $cassandra_optutils_package = 'cassandra22-tools'
        $cassandra_package = 'cassandra22'
        $version = '2.2.5-1'
    } else {
        $cassandra_optutils_package = 'cassandra-tools'
        $cassandra_package = 'cassandra'
        $version = '2.2.5'
    }

    class { 'cassandra':
      cassandra_9822              => true,
      commitlog_directory_mode    => '0770',
      data_file_directories_mode  => '0770',
      listen_interface            => 'lo',
      package_ensure              => $version,
      package_name                => $cassandra_package,
      rpc_interface               => 'lo',
      saved_caches_directory_mode => '0770',
      service_systemd             => $service_systemd
    }

    $keyspaces = {
      'Excelsior' => {
        ensure => absent,
      }
    }

    if $::operatingsystem != CentOS and $::operatingsystemmajrelease != 6 {
      class { 'cassandra::schema':
        keyspaces => $keyspaces,
      }
    }
  EOS

  describe '########### Schema drop (Keyspaces).' do
    it 'should work with no errors' do
      apply_manifest(schema_testing_drop_pp, catch_failures: true)
    end
    it 'check code is idempotent' do
      expect(apply_manifest(schema_testing_drop_pp,
                            catch_failures: true).exit_code).to be_zero
    end
  end

   cassandra_uninstall22_pp = <<-EOS
     if $::osfamily == 'RedHat' {
         $cassandra_optutils_package = 'cassandra22-tools'
         $cassandra_package = 'cassandra22'
     } else {
         $cassandra_optutils_package = 'cassandra-tools'
         $cassandra_package = 'cassandra'
     }
  
     package { $cassandra_optutils_package:
       ensure => absent
     } ->
     package { $cassandra_package:
       ensure => absent
     }
   EOS
  
   cassandra_upgrade30_pp = <<-EOS
     if $::osfamily == 'RedHat' and $::operatingsystemmajrelease == 7 {
         $service_systemd = true
     } elsif $::operatingsystem == 'Debian'
       and $::operatingsystemmajrelease == 8 {
         $service_systemd = true
     } else {
         $service_systemd = false
     }
  
     if $::osfamily == 'RedHat' {
         $cassandra_optutils_package = 'cassandra30-tools'
         $cassandra_package = 'cassandra30'
         $version = '3.0.3-1'
     } else {
         $cassandra_optutils_package = 'cassandra-tools'
         $cassandra_package = 'cassandra'
         $version = '3.0.3'
      }
  
     class { 'cassandra':
       cassandra_9822              => true,
       commitlog_directory_mode    => '0770',
       data_file_directories_mode  => '0770',
       listen_interface            => 'lo',
       package_ensure              => $version,
       package_name                => $cassandra_package,
       rpc_interface               => 'lo',
       saved_caches_directory_mode => '0770',
       service_systemd             => $service_systemd
     }
  
     class { 'cassandra::optutils':
       ensure       => $version,
       package_name => $cassandra_optutils_package,
       require      => Class['cassandra']
     }
   EOS
  
   describe '########### Uninstall Cassandra 2.2.' do
     it 'should work with no errors' do
       apply_manifest(cassandra_uninstall22_pp, catch_failures: true)
     end
   end
   describe '########### Cassandra 3.0 installation.' do
     it 'should work with no errors' do
       apply_manifest(cassandra_upgrade30_pp, catch_failures: true)
     end
     it 'check code is idempotent' do
       expect(apply_manifest(cassandra_upgrade30_pp,
                             catch_failures: true).exit_code).to be_zero
     end
    end
  
   describe service('cassandra') do
     it { is_expected.to be_running }
     it { is_expected.to be_enabled }
   end

  check_against_previous_version_pp = <<-EOS
    class { 'cassandra':
      cassandra_9822              => true,
      commitlog_directory_mode    => '0770',
      data_file_directories_mode  => '0770',
      saved_caches_directory_mode => '0770',
    }
  EOS

  describe '########### Ensure config file does get updated.' do
    it 'Initial install manifest again' do
      apply_manifest(check_against_previous_version_pp,
                     catch_failures: true)
    end
    it 'Copy the current module to the side without error.' do
      shell('cp -R /etc/puppet/modules/cassandra /var/tmp',
            acceptable_exit_codes: 0)
    end
    it 'Remove the current module without error.' do
      shell('puppet module uninstall locp-cassandra',
            acceptable_exit_codes: 0)
    end
    it 'Install the latest module from the forge.' do
      shell('puppet module install locp-cassandra',
            acceptable_exit_codes: 0)
    end
    it 'Check install works without changes with previous module version.' do
      expect(apply_manifest(check_against_previous_version_pp,
                            catch_failures: true).exit_code).to be_zero
    end
  end

  describe '########### Gather service information (when in debug mode).' do
    it 'Show the cassandra system log.' do
      shell('grep -v \'^INFO\' /var/log/cassandra/system.log')
    end
  end
end
