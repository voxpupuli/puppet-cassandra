require 'spec_helper_acceptance'

describe 'cassandra class' do
  cassandra_version = ['2.2.7']

  cassandra_version.each do |version|
    cassandra_install_pp = <<-EOS
      if $::osfamily == 'RedHat' {
        $skip = false

        if $::operatingsystemmajrelease >= 7 {
          $service_systemd = true
        } else {
          $service_systemd = false
        }

        $cassandra_optutils_package = 'cassandra22-tools'
        $cassandra_package = 'cassandra22'
        $version = '#{version}-1'

        class { 'cassandra::java':
          before => Class['cassandra']
        }
      } else {
        $service_systemd = false
        $cassandra_optutils_package = 'cassandra-tools'
        $cassandra_package = 'cassandra'
        $version = '#{version}'

        if $::lsbdistid == 'Ubuntu' {
          if $::operatingsystemmajrelease >= 16 {
            $skip = true
          } else {
            $skip = false
          }

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
          $skip = false

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
        exec { '/bin/chown root:root /etc/apt/sources.list.d/datastax.list':
          unless  => '/usr/bin/test -O /etc/apt/sources.list.d/datastax.list',
          require => Class['cassandra::datastax_agent']
        }
      }

      class { 'cassandra::datastax_repo': }

      if $skip == false {
        class { 'cassandra':
          cassandra_9822              => true,
          dc                          => 'LON',
          package_ensure              => $version,
          package_name                => $cassandra_package,
          rack                        => 'R101',
          service_systemd             => $service_systemd,
          settings                    => {
            'authenticator'               => 'PasswordAuthenticator',
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
          },
          require                     => Class['cassandra::datastax_repo'],
        }

        class { 'cassandra::optutils':
          package_ensure => $version,
          package_name   => $cassandra_optutils_package,
          require        => Class['cassandra']
        }

        class { 'cassandra::datastax_agent':
          require => Class['cassandra'],
        }
      }

      # This really sucks but Docker, CentOS 6 and iptables don't play nicely
      # together.  Therefore we can't test the firewall on this platform :-(
      if $::operatingsystem != CentOS and $::operatingsystemmajrelease != 6 {
        include '::cassandra::firewall_ports'
      }
    EOS

    describe "########### Cassandra #{version} installation." do
      it 'should work with no errors' do
        apply_manifest(cassandra_install_pp, catch_failures: true)
      end
      it 'check code is idempotent' do
        expect(apply_manifest(cassandra_install_pp,
                              catch_failures: true).exit_code).to be_zero
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

    schema_testing_create_pp = <<-EOS
    if $::osfamily == 'RedHat' {
        $cassandra_optutils_package = 'cassandra22-tools'
        $cassandra_package = 'cassandra22'
        $version = '#{version}-1'
    } else {
        $cassandra_optutils_package = 'cassandra-tools'
        $cassandra_package = 'cassandra'
        $version = '#{version}'
    }

    class { 'cassandra':
      cassandra_9822              => true,
      dc                          => 'LON',
      package_ensure              => $version,
      package_name                => $cassandra_package,
      rack                        => 'R101',
      settings                    => {
        'authenticator'               => 'PasswordAuthenticator',
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
      },
    }

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

    if $::operatingsystem != CentOS {
      $os_ok = true
    } else {
      if $::operatingsystemmajrelease != 6 {
        $os_ok = true
      } else {
        $os_ok = false
      }
    }

    if $os_ok {
      class { 'cassandra::schema':
        cql_types      => $cql_types,
        cqlsh_host     => $::ipaddress,
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

    schema_testing_drop_type_pp = <<-EOS
    if $::osfamily == 'RedHat' {
        $cassandra_optutils_package = 'cassandra22-tools'
        $cassandra_package = 'cassandra22'
        $version = '#{version}-1'
    } else {
        $cassandra_optutils_package = 'cassandra-tools'
        $cassandra_package = 'cassandra'
        $version = '#{version}'
    }

    class { 'cassandra':
      cassandra_9822              => true,
      dc                          => 'LON',
      package_ensure              => $version,
      package_name                => $cassandra_package,
      rack                        => 'R101',
      settings                    => {
        'authenticator'               => 'PasswordAuthenticator',
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
      },
    }

    $cql_types = {
      'fullname' => {
        'keyspace' => 'mykeyspace',
        'ensure'   => 'absent'
      }
    }

    if $::operatingsystem != CentOS {
      $os_ok = true
    } else {
      if $::operatingsystemmajrelease != 6 {
        $os_ok = true
      } else {
        $os_ok = false
      }
    }

    if $os_ok {
      class { 'cassandra::schema':
        cql_types      => $cql_types,
        cqlsh_host     => $::ipaddress,
        cqlsh_user     => 'akers',
        cqlsh_password => 'Niner2',
      }
    }
  EOS

    describe '########### Schema drop type.' do
      it 'should work with no errors' do
        apply_manifest(schema_testing_drop_type_pp,
                       catch_failures: true)
      end
      it 'check code is idempotent' do
        expect(apply_manifest(schema_testing_drop_type_pp,
                              catch_failures: true).exit_code).to be_zero
      end
    end

    schema_testing_drop_user_pp = <<-EOS
    if $::osfamily == 'RedHat' {
        $cassandra_optutils_package = 'cassandra22-tools'
        $cassandra_package = 'cassandra22'
        $version = '#{version}-1'
    } else {
        $cassandra_optutils_package = 'cassandra-tools'
        $cassandra_package = 'cassandra'
        $version = '#{version}'
    }

    class { 'cassandra':
      cassandra_9822              => true,
      dc                          => 'LON',
      package_ensure              => $version,
      package_name                => $cassandra_package,
      rack                        => 'R101',
      settings                    => {
        'authenticator'               => 'PasswordAuthenticator',
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
      },
    }

    if $::operatingsystem != CentOS {
      $os_ok = true
    } else {
      if $::operatingsystemmajrelease != 6 {
        $os_ok = true
      } else {
        $os_ok = false
      }
    }

    if $os_ok {
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

    schema_testing_drop_index_pp = <<-EOS
    if $::osfamily == 'RedHat' {
        $cassandra_optutils_package = 'cassandra22-tools'
        $cassandra_package = 'cassandra22'
        $version = '#{version}-1'
    } else {
        $cassandra_optutils_package = 'cassandra-tools'
        $cassandra_package = 'cassandra'
        $version = '#{version}'
    }

    class { 'cassandra':
      cassandra_9822              => true,
      dc                          => 'LON',
      package_ensure              => $version,
      package_name                => $cassandra_package,
      rack                        => 'R101',
      settings                    => {
        'authenticator'               => 'PasswordAuthenticator',
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
      },
    }

    if $::operatingsystem != CentOS {
      $os_ok = true
    } else {
      if $::operatingsystemmajrelease != 6 {
        $os_ok = true
      } else {
        $os_ok = false
      }
    }

    if $os_ok {
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
    }
  EOS

    describe '########### Schema drop index.' do
      it 'should work with no errors' do
        apply_manifest(schema_testing_drop_index_pp,
                       catch_failures: true)
      end
      it 'check code is idempotent' do
        expect(apply_manifest(schema_testing_drop_index_pp,
                              catch_failures: true).exit_code).to be_zero
      end
    end

    schema_testing_drop_pp = <<-EOS
    if $::osfamily == 'RedHat' {
        $cassandra_optutils_package = 'cassandra22-tools'
        $cassandra_package = 'cassandra22'
        $version = '#{version}-1'
    } else {
        $cassandra_optutils_package = 'cassandra-tools'
        $cassandra_package = 'cassandra'
        $version = '#{version}'
    }

    class { 'cassandra':
      cassandra_9822              => true,
      dc                          => 'LON',
      package_ensure              => $version,
      package_name                => $cassandra_package,
      rack                        => 'R101',
      settings                    => {
        'authenticator'               => 'PasswordAuthenticator',
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
      },
    }

    if $::operatingsystem != CentOS {
      $os_ok = true
    } else {
      if $::operatingsystemmajrelease != 6 {
        $os_ok = true
      } else {
        $os_ok = false
      }
    }

    if $os_ok {
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
    }
  EOS

    describe '########### Schema drop (table).' do
      it 'should work with no errors' do
        apply_manifest(schema_testing_drop_pp, catch_failures: true)
      end
      it 'check code is idempotent' do
        expect(apply_manifest(schema_testing_drop_pp,
                              catch_failures: true).exit_code).to be_zero
      end
    end

    schema_testing_drop_pp = <<-EOS
    if $::osfamily == 'RedHat' {
        $cassandra_optutils_package = 'cassandra22-tools'
        $cassandra_package = 'cassandra22'
        $version = '#{version}-1'
    } else {
        $cassandra_optutils_package = 'cassandra-tools'
        $cassandra_package = 'cassandra'
        $version = '#{version}'
    }

    class { 'cassandra':
      cassandra_9822              => true,
      dc                          => 'LON',
      package_ensure              => $version,
      package_name                => $cassandra_package,
      rack                        => 'R101',
      settings                    => {
        'authenticator'               => 'PasswordAuthenticator',
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
      },
    }

    $keyspaces = {
      'mykeyspace' => {
        ensure => absent,
      }
    }

    if $::operatingsystem != CentOS {
      $os_ok = true
    } else {
      if $::operatingsystemmajrelease != 6 {
        $os_ok = true
      } else {
        $os_ok = false
      }
    }

    if $os_ok {
      class { 'cassandra::schema':
        cqlsh_host     => $::ipaddress,
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

    describe '########### Gather service information (when in debug mode).' do
      it 'Show the cassandra system log.' do
        shell("grep -v -e '^INFO' -e '^\s*INFO' /var/log/cassandra/system.log")
      end
    end
  end
end
