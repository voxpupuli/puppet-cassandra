# Create a cluster called MyCassandraCluster with java installed and alternative repository

include java

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
  repo_config       => {
    datastax => {
      baseurl  => 'http://rpm.datastax.com/community',
      gpgcheck => 0,
      enabled  => 1,
    },
  },
  require           => Class['java'],
}
