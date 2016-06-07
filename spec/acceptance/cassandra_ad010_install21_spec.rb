require 'spec_helper_acceptance'

describe 'cassandra class' do
  cassandra_upgrade21_pp = <<-EOS
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
end
