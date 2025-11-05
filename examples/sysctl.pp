# Create a cluster called MyCassandraCluster with java installed and sysctl parameters

$_sysctl = {
  'net.core.optmem_max'   => 40960,
  'net.core.rmem_default' => 16777216,
  'net.core.rmem_max'     => 16777216,
  'net.core.wmem_default' => 16777216,
  'net.core.wmem_max'     => 16777216,
  'net.ipv4.tcp_rmem'     => '4096 87380 16777216',
  'net.ipv4.tcp_wmem'     => '4096 65536 16777216',
  'vm.max_map_count'      => 1048575,
}

$_sysctl.each |$_key, $_value| {
  sysctl { $_key:
    ensure => present,
    value  => $_value,
    before => Class['cassandra'],
  }
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

Class['java'] -> Class['cassandra']
