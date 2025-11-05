# Create a cluster called MyCassandraCluster with java installed and firewall rules

include java

[7000, 7001, 9042, 9160, 9142].each |$_port| {
  firewall { "allow port ${_port}/tcp":
    dport => $_port,
    proto => 'tcp',
    jump  => 'accept',
  }
}

class { 'cassandra':
  baseline_settings => {
    authenticator               => 'AllowAllAuthenticator',
    authorizer                  => 'AllowAllAuthorizer',
    cluster_name                => 'MyCassandraCluster',
    commitlog_sync              => 'periodic',
    commitlog_sync_period_in_ms => 10000,
    listen_interface            => $facts['networking']['primary'],
    endpoint_snitch             => 'SimpleSnitch',
    partitioner                 => 'org.apache.cassandra.dht.Murmur3Partitioner',
    seed_provider               => [
      {
        class_name => 'org.apache.cassandra.locator.SimpleSeedProvider',
        parameters => [
          {
            seeds => $facts['networking']['ip']
          },
        ],
      },
    ],
  },
  require           => Class['java'],
}
