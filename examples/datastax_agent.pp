# Create a cluster called MyCassandraCluster with java installed, an alternative repository and the datastax agent

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

package { 'datastax-agent':
  ensure  => present,
  require => Class['cassandra'],
}

cassandra::file { 'Set JAVA_HOME for datastax-agent':
  file       => 'datastax-agent',
  file_lines => {
    'JAVA_HOME'  => {
      line  => "JAVA_HOME=${java::java_home}",
      match => '^#?JAVA_HOME=.*',
    },
  },
  require    => Package['datastax-agent'],
}
