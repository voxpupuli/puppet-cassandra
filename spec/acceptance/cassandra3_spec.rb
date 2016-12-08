require 'spec_helper_acceptance'

describe 'cassandra3' do
  version = '3.0.9'
  lsbdistid = fact('lsbdistid')
  lsbmajdistrelease = fact('lsbmajdistrelease')
  osdisplay = "#{lsbdistid}#{lsbmajdistrelease}"

  legacy_yml_dump = if (osdisplay == 'CentOS6') || (osdisplay == 'Ubuntu1204')
                      true
                    else
                      false
                    end

  cassandra_install_pp = <<-EOS
    include cassandra::datastax_repo
    include cassandra::java

    $version = '#{version}'

    if $::osfamily == 'RedHat' {
      $package_ensure = "${version}-1"
      $cassandra_optutils_package = 'cassandra30-tools'
      $cassandra_package = 'cassandra30'
    } else {
      $cassandra_optutils_package = 'cassandra-tools'
      $cassandra_package = 'cassandra'
      $package_ensure = $version

      if $::lsbdistid == 'Ubuntu' {
        if $::operatingsystemmajrelease >= 16 {
          # Workarounds for amonst other things CASSANDRA-11850
          Exec {
            environment => [ 'CQLSH_NO_BUNDLED=TRUE' ]
          }
        }
      }

      exec { '/bin/chown root:root /etc/apt/sources.list.d/datastax.list':
        unless  => '/usr/bin/test -O /etc/apt/sources.list.d/datastax.list',
        require => Class['cassandra::datastax_agent']
      }
    }

    $settings = {
      'authenticator'               => 'PasswordAuthenticator',
      'cluster_name'                => 'MyCassandraCluster',
      'commitlog_directory'         => '/var/lib/cassandra/commitlog',
      'commitlog_sync'              => 'periodic',
      'commitlog_sync_period_in_ms' => 10000,
      'data_file_directories'       => ['/var/lib/cassandra/data'],
      'endpoint_snitch'             => 'GossipingPropertyFileSnitch',
      'hints_directory'             => '/var/lib/cassandra/hints',
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

    if versioncmp($::rubyversion, '1.9.0') < 0 {
      $service_refresh = false
    } else {
      $service_refresh = true
    }

    class { 'cassandra':
      package_ensure  => $package_ensure,
      package_name    => $cassandra_package,
      service_refresh => $service_refresh,
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

  describe "########### Cassandra #{version} installation on #{osdisplay}" do
    it 'should work with no errors' do
      apply_manifest(cassandra_install_pp, catch_failures: true)
    end

    if legacy_yml_dump
      it 'should work with no errors (subsequent run)' do
        apply_manifest(cassandra_install_pp, catch_failures: true)
      end
    else
      it 'check code is idempotent' do
        expect(apply_manifest(cassandra_install_pp,
                              catch_failures: true).exit_code).to be_zero
      end
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
      users          => {
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
  EOS

  describe "########### Schema create #{version} on #{osdisplay}." do
    it 'should work with no errors' do
      apply_manifest(schema_testing_create_pp, catch_failures: true)
    end

    if legacy_yml_dump
      it 'should work with no errors (subsequent run)' do
        apply_manifest(schema_testing_create_pp, catch_failures: true)
      end
    else
      it 'check code is idempotent' do
        expect(apply_manifest(schema_testing_create_pp, catch_failures: true).exit_code).to be_zero
      end
    end
  end

  schema_testing_drop_type_pp = <<-EOS
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

  describe "########### Schema drop type #{version} on #{osdisplay}." do
    it 'should work with no errors' do
      apply_manifest(schema_testing_drop_type_pp, catch_failures: true)
    end

    if legacy_yml_dump
      it 'should work with no errors (subsequent run)' do
        apply_manifest(schema_testing_drop_type_pp, catch_failures: true)
      end
    else
      it 'check code is idempotent' do
        expect(apply_manifest(schema_testing_drop_type_pp, catch_failures: true).exit_code).to be_zero
      end
    end
  end

  schema_testing_drop_user_pp = <<-EOS
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

  describe "########### Drop the boone user #{version} on #{osdisplay}." do
    it 'should work with no errors' do
      apply_manifest(schema_testing_drop_user_pp, catch_failures: true)
    end

    if legacy_yml_dump
      it 'should work with no errors (subsequent run)' do
        apply_manifest(schema_testing_drop_user_pp, catch_failures: true)
      end
    else
      it 'check code is idempotent' do
        expect(apply_manifest(schema_testing_drop_user_pp, catch_failures: true).exit_code).to be_zero
      end
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

  describe "########### Schema drop index #{version} on #{osdisplay}." do
    it 'should work with no errors' do
      apply_manifest(schema_testing_drop_index_pp, catch_failures: true)
    end

    if legacy_yml_dump
      it 'should run with no errors (subsequent run)' do
        apply_manifest(schema_testing_drop_index_pp, catch_failures: true)
      end
    else
      it 'check code is idempotent' do
        expect(apply_manifest(schema_testing_drop_index_pp, catch_failures: true).exit_code).to be_zero
      end
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

  describe "########### Schema drop (table) #{version} on #{osdisplay}." do
    it 'should work with no errors' do
      apply_manifest(schema_testing_drop_pp, catch_failures: true)
    end

    if legacy_yml_dump
      it 'should work with no errors (subsequent run)' do
        apply_manifest(schema_testing_drop_pp, catch_failures: true)
      end
    else
      it 'check code is idempotent' do
        expect(apply_manifest(schema_testing_drop_pp, catch_failures: true).exit_code).to be_zero
      end
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

  describe "########### Schema drop (Keyspaces) #{version} on #{osdisplay}." do
    it 'should work with no errors' do
      apply_manifest(schema_testing_drop_pp, catch_failures: true)
    end
    if legacy_yml_dump
      it 'should work with no errors (subsequent run)' do
        apply_manifest(schema_testing_drop_pp, catch_failures: true)
      end
    else
      it 'check code is idempotent' do
        expect(apply_manifest(schema_testing_drop_pp, catch_failures: true).exit_code).to be_zero
      end
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
  EOS

  describe "########### Facts Tests #{version} on #{osdisplay}." do
    it 'should work with no errors' do
      apply_manifest(facts_testing_pp, catch_failures: true)
    end
  end

  describe '########### Gather service information (when in debug mode).' do
    it 'Show the cassandra system log.' do
      shell("grep -v -e '^INFO' -e '^\s*INFO' /var/log/cassandra/system.log")
    end
  end
end
