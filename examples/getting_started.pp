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
  cluster_name    => 'MyCassandraCluster',
  endpoint_snitch => 'GossipingPropertyFileSnitch',
  listen_address  => $::ipaddress,
  seeds           => $::ipaddress,
  service_systemd => true,
  require         => Class['cassandra::datastax_repo', 'cassandra::java'],
}

cassandra::schema::keyspace { 'mykeyspace':
  replication_map => {
    keyspace_class     => 'SimpleStrategy',
    replication_factor => 1,
  },
  durable_writes  => false,
}

cassandra::schema::table { 'users':
  columns  => {
    user_id       => 'int',
    fname         => 'text',
    lname         => 'text',
    'PRIMARY KEY' => '(user_id)',
  },
  keyspace => 'mykeyspace',
}

cassandra::schema::index { 'users_lname_idx':
  table    => 'users',
  keys     => 'lname',
  keyspace => 'mykeyspace',
}
