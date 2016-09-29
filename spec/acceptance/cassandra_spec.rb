require 'spec_helper_acceptance'

describe 'cassandra::java' do
  install_java_pp = <<-EOS
    if $::osfamily == 'RedHat' {
      include 'cassandra::java'
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
    }
  EOS

  describe '########### Java installation.' do
    it 'should work with no errors' do
      apply_manifest(install_java_pp, catch_failures: true)
    end
    it 'check code is idempotent' do
      expect(apply_manifest(install_java_pp,
                            catch_failures: true).exit_code).to be_zero
    end
  end
end

describe 'cassandra::datastax_repo' do
  install_datastax_repo_pp = <<-EOS
    class { 'cassandra::datastax_repo': }
  EOS

  describe '########### DataStax Repository installation.' do
    it 'should work with no errors' do
      apply_manifest(install_datastax_repo_pp, catch_failures: true)
    end
    it 'check code is idempotent' do
      expect(apply_manifest(install_datastax_repo_pp,
                            catch_failures: true).exit_code).to be_zero
    end
  end
end

describe 'cassandra' do
  nodeset = ENV['BEAKER_set']
  opsys = nodeset.split('_')[1]

  # Ubuntu 16 only works with Cassandra 3.X
  cassandra_version = if opsys == 'ubuntu16'
                        ['3.0.3']
                      else
                        ['2.2.7', '3.0.3']
                      end

  ruby_lt_190 = case opsys
                when 'centos6' then true
                when 'ubuntu12' then true
                else false
                end

  cassandra_version.each do |version|
    cassandra_install_pp = <<-EOS
      if $::osfamily == 'RedHat' {
        $version = '#{version}-1'

        if $version == '2.2.7-1' {
          $cassandra_optutils_package = 'cassandra22-tools'
          $cassandra_package = 'cassandra22'
        } else {
          $cassandra_optutils_package = 'cassandra30-tools'
          $cassandra_package = 'cassandra30'
        }
      } else {
        $cassandra_optutils_package = 'cassandra-tools'
        $cassandra_package = 'cassandra'
        $version = '#{version}'

        if $::lsbdistid == 'Ubuntu' {
          if $::operatingsystemmajrelease >= 16 {
            # Workarounds for amonst other things CASSANDRA-11850
            Exec {
              environment => [ 'CQLSH_NO_BUNDLED=TRUE' ]
            }

            exec { '/usr/bin/wget http://launchpadlibrarian.net/109052632/python-support_1.0.15_all.deb':
              cwd     => '/var/tmp',
              creates => '/var/tmp/python-support_1.0.15_all.deb',
            } ~>
            exec { '/usr/bin/dpkg -i /var/tmp/python-support_1.0.15_all.deb':
              refreshonly => true,
            } ->
            package { 'cassandra-driver':
              provider => 'pip',
              before   => Class['cassandra']
            }
          }
        }

        exec { '/bin/chown root:root /etc/apt/sources.list.d/datastax.list':
          unless  => '/usr/bin/test -O /etc/apt/sources.list.d/datastax.list',
          require => Class['cassandra::datastax_agent']
        }
      }

      $initial_settings = {
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
      }

      if $version =~ /^2/ {
        $settings = $initial_settings
      } else {
        $settings = merge($initial_settings, { 'hints_directory' => '/var/lib/cassandra/hints' })
      }


      if versioncmp($::rubyversion, '1.9.0') < 0 {
        $service_refresh = false
      } else {
        $service_refresh = true
      }

      class { 'cassandra':
        cassandra_9822  => true,
        dc              => 'LON',
        package_ensure  => $version,
        package_name    => $cassandra_package,
        rack            => 'R101',
        service_ensure  => running,
        service_refresh => $service_refresh,
        settings        => $settings,
      }

      class { 'cassandra::optutils':
        package_ensure => $version,
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

    datastax_agent_cludge_pp = <<-EOS
      Exec {
        path => [ '/usr/bin', '/bin'],
      }

      exec { 'chmod 0640 /var/lib/datastax-agent/conf/address.yaml': }
    EOS

    describe "########### Cassandra #{version} installation (#{opsys})." do
      it 'should work with no errors' do
        apply_manifest(cassandra_install_pp, catch_failures: true)
      end

      it 'Give Cassandra a minute to fully come alive.' do
        sleep 60
      end

      if ruby_lt_190
        it 'should work with no errors (subsequent run)' do
          apply_manifest(cassandra_install_pp, catch_failures: true)
        end
      else
        it 'check code is idempotent' do
          apply_manifest(datastax_agent_cludge_pp, catch_failures: true)
          expect(apply_manifest(cassandra_install_pp,
                                catch_failures: true).exit_code).to be_zero
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
      }
    EOS

    describe '########### Schema create.' do
      it 'should work with no errors' do
        apply_manifest(schema_testing_create_pp, catch_failures: true)
      end

      if ruby_lt_190
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
        apply_manifest(schema_testing_drop_type_pp, catch_failures: true)
      end

      if ruby_lt_190
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

      if ruby_lt_190
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
        apply_manifest(schema_testing_drop_index_pp, catch_failures: true)
      end

      if ruby_lt_190
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

      if ruby_lt_190
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
      if ruby_lt_190
        it 'should work with no errors (subsequent run)' do
          apply_manifest(schema_testing_drop_pp, catch_failures: true)
        end
      else
        it 'check code is idempotent' do
          expect(apply_manifest(schema_testing_drop_pp, catch_failures: true).exit_code).to be_zero
        end
      end
    end

    describe '########### Gather service information (when in debug mode).' do
      it 'Show the cassandra system log.' do
        shell("grep -v -e '^INFO' -e '^\s*INFO' /var/log/cassandra/system.log")
      end
    end

    next unless version != cassandra_version.last

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

    describe '########### Uninstall Cassandra 2.2.' do
      it 'should work with no errors' do
        apply_manifest(cassandra_uninstall_pp, catch_failures: true)
      end
    end
  end
end
