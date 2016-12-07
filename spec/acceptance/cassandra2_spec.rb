require 'spec_helper_acceptance'

describe 'cassandra2', unless: CASSANDRA2_UNSUPPORTED_PLATFORMS.include?(fact('lsbdistrelease')) do
  cassandra_install_pp = <<-EOS
    include cassandra::datastax_repo
    include cassandra::java

    $version = '2.2.8'

    if $::osfamily == 'RedHat' {
      $package_ensure = "${version}-1"
      $cassandra_optutils_package = 'cassandra22-tools'
      $cassandra_package = 'cassandra22'
    } else {
      $package_ensure = $version
      $cassandra_optutils_package = 'cassandra-tools'
      $cassandra_package = 'cassandra'

      exec { '/bin/chown root:root /etc/apt/sources.list.d/datastax.list':
        unless  => '/usr/bin/test -O /etc/apt/sources.list.d/datastax.list',
        require => Class['cassandra::datastax_agent']
      }
    }

    $settings = {
      'authenticator'               => 'PasswordAuthenticator',
      'authorizer'                  => 'CassandraAuthorizer',
      'cluster_name'                => 'MyCassandraCluster',
      'commitlog_directory'         => '/var/lib/cassandra/commitlog',
      'commitlog_sync'              => 'periodic',
      'commitlog_sync_period_in_ms' => 10000,
      'data_file_directories'       => ['/var/lib/cassandra/data'],
      'endpoint_snitch'             => 'GossipingPropertyFileSnitch',
      'listen_address'              => $::ipaddress,
      'partitioner'                 => 'org.apache.cassandra.dht.Murmur3Partitioner',
      'saved_caches_directory'      => '/var/lib/cassandra/saved_caches',
      'seed_provider'               => [
        {
          'class_name' => 'org.apache.cassandra.locator.SimpleSeedProvider',
          'parameters' => [
            {
              'seeds' => $::ipaddress,
            },
          ],
        },
      ],
      'start_native_transport'      => true,
    }

    class { 'cassandra':
      package_ensure  => $package_ensure,
      package_name    => $cassandra_package,
      settings        => $settings,
      require         => Class['cassandra::datastax_repo', 'cassandra::java']
    }

    class { 'cassandra::optutils':
      package_ensure => $package_ensure,
      package_name   => $cassandra_optutils_package,
      require        => Class['cassandra']
    }

    class { 'cassandra::datastax_agent':
      require => Class['cassandra']
    }

    # This really sucks but Docker, CentOS 6 and iptables don't play nicely
    # together.  Therefore we can't test the firewall on this platform :-(
    if $::operatingsystem != CentOS and $::operatingsystemmajrelease != 6 {
      include '::cassandra::firewall_ports'
    }
  EOS

  describe '########### Cassandra installation.' do
    it 'should work with no errors' do
      apply_manifest(cassandra_install_pp, catch_failures: true)
    end

    it 'check code is idempotent' do
      expect(apply_manifest(cassandra_install_pp,
                            catch_failures: true).exit_code).to be_zero
    end
  end

  schema_testing_create_pp = <<-EOS
    #{cassandra_install_pp}

    $cql_types = {
      'fullname' => {
        'keyspace' => 'mykeyspace',
        'fields'   => {
        'fname' => 'text',
          'lname' => 'text',
        },
      },
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

    class { 'cassandra::schema':
      cql_types      => $cql_types,
      cqlsh_host     => $::ipaddress,
      cqlsh_password => 'cassandra',
      cqlsh_user     => 'cassandra',
      indexes        => {
        'users_lname_idx' => {
          keyspace => 'mykeyspace',
          table    => 'users',
          keys     => 'lname',
        },
      },
      keyspaces      => $keyspaces,
      tables         => {
        'users' => {
          'keyspace' => 'mykeyspace',
          'columns'  => {
            'userid'      => 'int',
            'fname'       => 'text',
            'lname'       => 'text',
            'PRIMARY KEY' => '(userid)',
          },
        },
      },
      permissions    => {
        'Grant select permissions to spillman to all keyspaces' => {
          permission_name => 'SELECT',
          user_name       => 'spillman',
        },
        'Grant modify to to keyspace mykeyspace to akers'       => {
          keyspace_name   => 'mykeyspace',
          permission_name => 'MODIFY',
          user_name       => 'akers',
        },
        'Grant alter permissions to mykeyspace to boone'        => {
          keyspace_name   => 'mykeyspace',
          permission_name => 'ALTER',
          user_name       => 'boone',
        },
        'Grant ALL permissions to mykeyspace.users to gbennet'  => {
          keyspace_name   => 'mykeyspace',
          permission_name => 'ALTER',
          table_name      => 'users',
          user_name       => 'gbennet',
        },
      },
      users          => {
        'akers'    => {
          password  => 'Niner2',
          superuser => true,
        },
        'boone'    => {
          password => 'Niner75',
        },
        'gbennet' => {
          password => 'Strewth',
        },
        'spillman' => {
          password => 'Niner27',
        },
      },
    }
  EOS

  describe '########### Schema create.' do
    it 'should work with no errors' do
      apply_manifest(schema_testing_create_pp, catch_failures: true)
    end

    it 'check code is idempotent' do
      expect(apply_manifest(schema_testing_create_pp, catch_failures: true).exit_code).to be_zero
    end
  end

  schema_drop_type_pp = <<-EOS
   #{cassandra_install_pp}

   $cql_types = {
     'fullname' => {
       'keyspace' => 'mykeyspace',
       'ensure'   => 'absent'
     }
   }

   class { 'cassandra::schema':
     cql_types      => $cql_types,
     cqlsh_host     => $::ipaddress,
     cqlsh_user     => 'akers',
     cqlsh_password => 'Niner2',
   }
  EOS

  describe '########### Schema drop type.' do
    it 'should work with no errors' do
      apply_manifest(schema_drop_type_pp, catch_failures: true)
    end

    it 'check code is idempotent' do
      expect(apply_manifest(schema_drop_type_pp, catch_failures: true).exit_code).to be_zero
    end
  end

  permissions_revoke_pp = <<-EOS
    #{cassandra_install_pp}

    class { 'cassandra::schema':
      cqlsh_password      => 'Niner2',
      cqlsh_host          => $::ipaddress,
      cqlsh_user          => 'akers',
      cqlsh_client_config => '/root/.puppetcqlshrc',
      permissions    => {
        'Revoke select permissions to spillman to all keyspaces' => {
          ensure          => absent,
          permission_name => 'SELECT',
          user_name       => 'spillman',
        },
        'Revoke modify to to keyspace mykeyspace to akers'       => {
          ensure          => absent,
          keyspace_name   => 'mykeyspace',
          permission_name => 'MODIFY',
          user_name       => 'akers',
        },
        'Revoke alter permissions to mykeyspace to boone'        => {
          ensure          => absent,
          keyspace_name   => 'mykeyspace',
          permission_name => 'ALTER',
          user_name       => 'boone',
        },
        'Revoke ALL permissions to mykeyspace.users to gbennet'  => {
          ensure          => absent,
          keyspace_name   => 'mykeyspace',
          permission_name => 'ALTER',
          table_name      => 'users',
          user_name       => 'gbennet',
        },
      },
    }
  EOS

  describe '########### Revoke permissions.' do
    it 'should work with no errors' do
      apply_manifest(permissions_revoke_pp, catch_failures: true)
    end

    it 'check code is idempotent' do
      expect(apply_manifest(permissions_revoke_pp, catch_failures: true).exit_code).to be_zero
    end
  end

  schema_drop_user_pp = <<-EOS
    #{cassandra_install_pp}

    class { 'cassandra::schema':
      cqlsh_password      => 'Niner2',
      cqlsh_host          => $::ipaddress,
      cqlsh_user          => 'akers',
      cqlsh_client_config => '/root/.puppetcqlshrc',
      users               => {
        'boone' => {
          ensure => absent,
        },
      },
    }
  EOS

  describe '########### Drop the boone user.' do
    it 'should work with no errors' do
      apply_manifest(schema_drop_user_pp, catch_failures: true)
    end

    it 'check code is idempotent' do
      expect(apply_manifest(schema_drop_user_pp, catch_failures: true).exit_code).to be_zero
    end
  end

  schema_testing_drop_index_pp = <<-EOS
    #{cassandra_install_pp}

     class { 'cassandra::schema':
     cqlsh_host     => $::ipaddress,
     cqlsh_user     => 'akers',
     cqlsh_password => 'Niner2',
     indexes        => {
       'users_lname_idx' => {
          ensure   => absent,
          keyspace => 'mykeyspace',
          table    => 'users',
         },
       },
     }
  EOS

  describe '########### Schema drop index.' do
    it 'should work with no errors' do
      apply_manifest(schema_testing_drop_index_pp, catch_failures: true)
    end

    it 'check code is idempotent' do
      expect(apply_manifest(schema_testing_drop_index_pp, catch_failures: true).exit_code).to be_zero
    end
  end

  schema_testing_drop_pp = <<-EOS
    #{cassandra_install_pp}

     class { 'cassandra::schema':
       cqlsh_host     => $ipaddress,
       cqlsh_password => 'Niner2',
       cqlsh_user     => 'akers',
       tables         => {
         'users' => {
           ensure   => absent,
           keyspace => 'mykeyspace',
         },
       },
     }
  EOS

  describe '########### Schema drop (table).' do
    it 'should work with no errors' do
      apply_manifest(schema_testing_drop_pp, catch_failures: true)
    end

    it 'check code is idempotent' do
      expect(apply_manifest(schema_testing_drop_pp, catch_failures: true).exit_code).to be_zero
    end
  end

  schema_testing_drop_pp = <<-EOS
    #{cassandra_install_pp}

    $keyspaces = {
      'mykeyspace' => {
        ensure => absent,
      }
    }

    class { 'cassandra::schema':
      cqlsh_host     => $::ipaddress,
      cqlsh_password => 'Niner2',
      cqlsh_user     => 'akers',
      keyspaces      => $keyspaces,
    }
  EOS

  describe '########### Schema drop (Keyspaces).' do
    it 'should work with no errors' do
      apply_manifest(schema_testing_drop_pp, catch_failures: true)
    end
    it 'check code is idempotent' do
      expect(apply_manifest(schema_testing_drop_pp, catch_failures: true).exit_code).to be_zero
    end
  end

  describe service('cassandra') do
    it do
      is_expected.to be_running
      is_expected.to be_enabled
    end
  end

  describe service('datastax-agent') do
    it do
      is_expected.to be_running
      is_expected.to be_enabled
    end
  end

  facts_testing_pp = <<-EOS
    #{cassandra_install_pp}

    if $::cassandrarelease != $version {
      fail("Test1: ${version} != ${::cassandrarelease}")
    }

    $assembled_version = "${::cassandramajorversion}.${::cassandraminorversion}.${::cassandrapatchversion}"

    if $version != $assembled_version {
      fail("Test2: ${version} != ${::assembled_version}")
    }

    if $::cassandramaxheapsize <= 0 {
      fail('cassandramaxheapsize is not set.')
    }
    if $::cassandracmsmaxheapsize <= 0 {
      fail('cassandracmsmaxheapsize is not set.')
    }
    if $::cassandraheapnewsize <= 0 {
      fail('cassandraheapnewsize is not set.')
    }
    if $::cassandracmsheapnewsize <= 0 {
      fail('cassandracmsheapnewsize is not set.')
    }
  EOS

  describe '########### Facts Tests.' do
    it 'should work with no errors' do
      apply_manifest(facts_testing_pp, catch_failures: true)
    end
  end

  describe '########### Gather service information (when in debug mode).' do
    it 'Show the cassandra system log.' do
      shell("grep -v -e '^INFO' -e '^\s*INFO' /var/log/cassandra/system.log")
    end
  end

  cassandra_uninstall_pp = <<-EOS
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
      $cassandra_optutils_package = 'cassandra22-tools'
      $cassandra_package = 'cassandra22'
    } else {
      $cassandra_optutils_package = 'cassandra-tools'
      $cassandra_package = 'cassandra'
    }

    service { 'cassandra':
      ensure => stopped,
    } ->
    package { $cassandra_optutils_package:
      ensure => absent
    } ->
    package { $cassandra_package:
      ensure => absent
    } ->
    exec { 'rm -rf /var/lib/cassandra/*/* /var/log/cassandra/*': }
  EOS

  describe '########### Uninstall Cassandra 2.' do
    it 'should work with no errors' do
      apply_manifest(cassandra_uninstall_pp, catch_failures: true)
    end
  end
end
