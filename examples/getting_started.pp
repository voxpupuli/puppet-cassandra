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

class { 'cassandra::optutils':
  require => Class['cassandra']
}

class { 'cassandra::schema':
  cqlsh_password => 'cassandra',
  cqlsh_user     => 'cassandra',
  indexes        => {
    'users_lname_idx' => {
      table    => 'users',
      keys     => 'lname',
      keyspace => 'mykeyspace',
    },
  },
  keyspaces      => {
    'mykeyspace' => {
      durable_writes  => false,
      replication_map => {
        keyspace_class     => 'SimpleStrategy',
        replication_factor => 1,
      },
    }
  },
  tables         => {
    'users' => {
      columns  => {
        user_id       => 'int',
        fname         => 'text',
        lname         => 'text',
        'PRIMARY KEY' => '(user_id)',
      },
      keyspace => 'mykeyspace',
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
    'lucan'    => {
      'ensure' => absent
    },
  },
}

if $::memorysize_mb < 24576.0 {
  $max_heap_size_in_mb = floor($::memorysize_mb / 2)
} elsif $::memorysize_mb < 8192.0 {
  $max_heap_size_in_mb = floor($::memorysize_mb / 4)
} else {
  $max_heap_size_in_mb = 8192
}

$heap_new_size = $::processorcount * 100

cassandra::file { "Set Java/Cassandra max heap size to ${max_heap_size_in_mb}.":
  file       => 'cassandra-env.sh',
  file_lines => {
    'MAX_HEAP_SIZE' => {
      line  => "MAX_HEAP_SIZE='${max_heap_size_in_mb}M'",
      match => '^#?MAX_HEAP_SIZE=.*',
    },
  }
}

cassandra::file { "Set Java/Cassandra heap new size to ${heap_new_size}.":
  file       => 'cassandra-env.sh',
  file_lines => {
    'HEAP_NEWSIZE'  => {
      line  => "HEAP_NEWSIZE='${heap_new_size}M'",
      match => '^#?HEAP_NEWSIZE=.*',
    }
  }
}
