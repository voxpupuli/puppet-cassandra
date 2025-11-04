# Create a cluster called MyCassandraCluster with java installed and transparant_hugepage defrag disabled

exec { 'disable transparent_hugepage defrag':
  command => 'echo never > /sys/kernel/mm/transparent_hugepage/defrag',
  path    => ['/usr/bin', '/usr/sbin'],
  unless  => "grep -q '\\[never\\]' /sys/kernel/mm/transparent_hugepage/defrag",
}

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
}

Exec['disable transparent_hugepage defrag'] -> Class['java'] -> Class['cassandra']
