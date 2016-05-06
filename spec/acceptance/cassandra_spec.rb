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

      class { 'cassandra::java':
        before => Class['cassandra']
      }
    } else {
      if $::lsbdistid == 'Ubuntu' {
        class { 'cassandra::java':
          aptkey       => {
            'openjdk-r' => {
              id     => 'DA1A4A13543B466853BAF164EB9B1D8886F44E2A',
              server => 'keyserver.ubuntu.com',
            },
          },
          aptsource    => {
            'openjdk-r' => {
              location => 'http://ppa.launchpad.net/openjdk-r/ppa/ubuntu',
              comment  => 'OpenJDK builds (all archs)',
              release  => $::lsbdistcodename,
              repos    => 'main',
            },
          },
          package_name => 'openjdk-8-jdk',
        }
      } else {
        class { 'cassandra::java':
          aptkey       => {
            'ZuluJDK' => {
              id     => '27BC0C8CB3D81623F59BDADCB1998361219BD9C9',
              server => 'keyserver.ubuntu.com',
            },
          },
          aptsource    => {
            'ZuluJDK' => {
              location => 'http://repos.azulsystems.com/debian',
              comment  => 'Zulu OpenJDK 8 for Debian',
              release  => 'stable',
              repos    => 'main',
            },
          },
          package_name => 'zulu-8',
        }
      }

      $cassandra_package = 'cassandra'
      $version = '2.0.17'

      exec { '/bin/chown root:root /etc/apt/sources.list.d/datastax.list':
        unless  => '/usr/bin/test -O /etc/apt/sources.list.d/datastax.list',
        require => Class['cassandra::opscenter']
      }
    }

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
      authenticator               => 'PasswordAuthenticator',
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
      before      => Class['::cassandra::opscenter'],
      require     => Class['::cassandra'],
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
      authenticator               => 'PasswordAuthenticator',
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
    Exec {
      path => [
        '/usr/local/bin',
        '/opt/local/bin',
        '/usr/bin',
        '/usr/sbin',
        '/bin',
        '/sbin'],
      logoutput => true,
    }

    if $::osfamily == 'RedHat' {
        $cassandra_optutils_package = 'cassandra21-tools'
        $cassandra_package = 'cassandra21'
    } else {
        $cassandra_optutils_package = 'cassandra-tools'
        $cassandra_package = 'cassandra'
    }

    package { [$cassandra_optutils_package, $cassandra_package ]:
      ensure => absent
    } ->
    exec { 'rm -rf /var/lib/cassandra/*/*': }
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
      authenticator               => 'PasswordAuthenticator',
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

    $heap_new_size = $::processorcount * 100

    class { 'cassandra::file':
      file       => 'cassandra-env.sh',
      file_lines => {
        'MAX_HEAP_SIZE' => {
          line  => 'MAX_HEAP_SIZE="1024M"',
          match => '#MAX_HEAP_SIZE="4G"',
        },
        'HEAP_NEWSIZE' => {
          line  => "HEAP_NEWSIZE='${heap_new_size}M'",
          match => '#HEAP_NEWSIZE="800M"',
        }
      }
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
      authenticator               => 'PasswordAuthenticator',
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
        cqlsh_password => 'cassandra',
        cqlsh_user     => 'cassandra',
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
        users     => {
          'spillman' => {
            password => 'Niner27',
          },
          'akers'    => {
            password  => 'Niner2',
            superuser => true,
          },
          'boone'    => {
            password => 'Niner75',
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
      authenticator               => 'PasswordAuthenticator',
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
        cql_types      => $cql_types,
        cqlsh_user     => 'akers',
        cqlsh_password => 'Niner2',
        indexes        => {
          'users_emails_idx' => {
             ensure   => absent,
             keyspace => 'Excalibur',
             table    => 'users',
          },
        },
        users          => {
          'spillman' => {
            ensure   => absent,
          },
          'akers'    => {
            password  => 'Niner2',
            superuser => true,
          },
          'boone'    => {
            password => 'Niner75',
          },
        },
      }
    }
  EOS

  describe '########### Schema drop (Indexes, Users & Types).' do
    it 'should work with no errors' do
      apply_manifest(schema_testing_drop__index_and_cql_type_pp,
                     catch_failures: true)
    end
    it 'check code is idempotent' do
      expect(apply_manifest(schema_testing_drop__index_and_cql_type_pp,
                            catch_failures: true).exit_code).to be_zero
    end
  end

  schema_testing_drop_user_pp = <<-EOS
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
      authenticator               => 'PasswordAuthenticator',
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
        cqlsh_password      => 'Niner2',
        cqlsh_user          => 'akers',
        cqlsh_client_config => '/root/.puppetcqlshrc',
        users               => {
          'boone' => {
            ensure => absent,
          },
        },
      }
    }
  EOS

  describe '########### Drop the boone user.' do
    it 'should work with no errors' do
      apply_manifest(schema_testing_drop_user_pp, catch_failures: true)
    end
    it 'check code is idempotent' do
      expect(apply_manifest(schema_testing_drop_user_pp,
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
      authenticator               => 'PasswordAuthenticator',
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
        cqlsh_password => 'Niner2',
        cqlsh_user     => 'akers',
        keyspaces      => $keyspaces,
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
       authenticator               => 'PasswordAuthenticator',
       cassandra_9822              => true,
       commitlog_directory_mode    => '0770',
       data_file_directories_mode  => '0770',
       hints_directory             => '/var/lib/cassandra/hints',
       listen_interface            => 'lo',
       package_ensure              => $version,
       package_name                => $cassandra_package,
       rpc_interface               => 'lo',
       saved_caches_directory_mode => '0770',
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

    it 'Give Cassandra 3.0 a minute to fully come alive.' do
      sleep 60
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
      authenticator               => 'PasswordAuthenticator',
      cassandra_9822              => true,
      commitlog_directory_mode    => '0770',
      data_file_directories_mode  => '0770',
      hints_directory             => '/var/lib/cassandra/hints',
      package_ensure              => $version,
      package_name                => $cassandra_package,
      saved_caches_directory_mode => '0770',
      service_systemd             => $service_systemd,
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
      shell("grep -v -e '^INFO' -e '^\s*INFO' /var/log/cassandra/system.log")
    end
  end
end
