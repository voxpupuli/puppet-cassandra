#############################################################################
# This is for placing in the getting started section of the README file.
#############################################################################
# Install Cassandra 2.2.5 onto a system and create a basic keyspace, table
# and index.  The node itself becomes a seed for the cluster.
#
# Tested on CentOS 7
#############################################################################

# Cassandra pre-requisites
include cassandra::datastax_repo
include cassandra::java

# Create a cluster called MyCassandraCluster which uses the
# GossipingPropertyFileSnitch.  In this very basic example
# the node itself becomes a seed for the cluster.
class { 'cassandra':
  authenticator   => 'PasswordAuthenticator',
  cluster_name    => 'MyCassandraCluster',
  endpoint_snitch => 'GossipingPropertyFileSnitch',
  listen_address  => $::ipaddress,
  seeds           => $::ipaddress,
  service_systemd => true,
  require         => Class['cassandra::datastax_repo', 'cassandra::java'],
}

class { 'cassandra::dse':
  file_lines => {
    'Set HADOOP_LOG_DIR directory' => {
      ensure => present,
      path   => '/etc/dse/dse-env.sh',
      line   => 'export HADOOP_LOG_DIR=/var/log/hadoop',
      match  => '^# export HADOOP_LOG_DIR=<log_dir>',
    },
    'Set DSE_HOME'                 => {
      ensure => present,
      path   => '/etc/dse/dse-env.sh',
      line   => 'export DSE_HOME=/usr/share/dse',
      match  => '^#export DSE_HOME',
    },
  },
  settings   => {
    ldap_options => {
      server_host                => localhost,
      server_port                => 389,
      search_dn                  => 'cn=Admin',
      search_password            => secret,
      use_ssl                    => false,
      use_tls                    => false,
      truststore_type            => jks,
      user_search_base           => 'ou=users,dc=example,dc=com',
      user_search_filter         => '(uid={0})',
      credentials_validity_in_ms => 0,
      connection_pool            => {
        max_active => 8,
        max_idle   => 8,
      }
    }
  }
}
