require 'spec_helper_acceptance'

describe 'cassandra class' do
  cassandra_install22_pp = <<-EOS
    if $::osfamily == 'RedHat' {
      $skip = false

      if $::operatingsystemmajrelease >= 7 {
        $service_systemd = true
      } else {
        $service_systemd = false
      }

      $cassandra_optutils_package = 'cassandra22-tools'
      $cassandra_package = 'cassandra22'
      $version = '2.2.5-1'

      class { 'cassandra::java':
        before => Class['cassandra']
      }
    } else {
      $service_systemd = false
      $cassandra_optutils_package = 'cassandra-tools'
      $cassandra_package = 'cassandra'
      $version = '2.2.5'

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
    }
  EOS

  describe '########### Cassandra 2.2 installation.' do
    it 'should work with no errors' do
      apply_manifest(cassandra_install22_pp, catch_failures: true)
    end
    it 'check code is idempotent' do
      expect(apply_manifest(cassandra_install22_pp,
                            catch_failures: true).exit_code).to be_zero
    end
  end
end
