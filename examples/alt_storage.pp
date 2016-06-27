#############################################################################
# Specify different storage locations
#############################################################################

# Cassandra pre-requisites
include cassandra::datastax_repo
include cassandra::java

# Specify the storage locations
$commitlog_directory = '/appdata/cassandra/commitlog'
$data_file_directory = '/appdata/cassandra/data'
$saved_caches_directory = '/appdata/cassandra/saved_caches'

file { '/appdata':
  ensure => directory,
  mode   => '0755',
} ->
file { '/appdata/cassandra':
  ensure  => directory,
  owner   => 'cassandra',
  group   => 'cassandra',
  require => Package['cassandra'],
  before  => Service['cassandra'],
} ->
file { [$commitlog_directory, $data_file_directory, $saved_caches_directory]:
  ensure  => directory,
  owner   => 'cassandra',
  group   => 'cassandra',
  require => Package['cassandra'],
  before  => Service['cassandra'],
}

# Create a cluster called MyCassandraCluster which uses the
# GossipingPropertyFileSnitch.  In this very basic example
# the node itself becomes a seed for the cluster.

class { 'cassandra':
  settings => {
    'authenticator'               => 'PasswordAuthenticator',
    'cluster_name'                => 'MyCassandraCluster',
    'commitlog_directory'         => $commitlog_directory,
    'commitlog_sync'              => 'periodic',
    'commitlog_sync_period_in_ms' => 10000,
    'data_file_directories'       => [$data_file_directory],
    'endpoint_snitch'             => 'GossipingPropertyFileSnitch',
    'listen_address'              => $::ipaddress,
    'partitioner'                 => 'org.apache.cassandra.dht.Murmur3Partitioner',
    'saved_caches_directory'      => $saved_caches_directory,
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
  require  => Class['cassandra::datastax_repo', 'cassandra::java'],
}

class { 'cassandra::datastax_agent':
  settings => {
    'agent_alias'     => {
      'setting' => 'agent_alias',
      'value'   => 'foobar',
    },
    'stomp_interface' => {
      'setting' => 'stomp_interface',
      'value'   => 'localhost',
    },
    'async_pool_size' => {
      'ensure' => absent,
    }
  },
  require  => Class['cassandra'],
}

class { 'cassandra::optutils':
  require => Class['cassandra']
}

class { 'cassandra::schema':
  cqlsh_password => 'cassandra',
  cqlsh_user     => 'cassandra',
  cqlsh_host     => $::ipaddress,
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

$heap_new_size = $::processorcount * 100

class { 'cassandra::file':
  file       => 'cassandra-env.sh',
  file_lines => {
    'MAX_HEAP_SIZE' => {
      line  => 'MAX_HEAP_SIZE="1024M"',
      match => '#MAX_HEAP_SIZE="4G"',
    },
    'HEAP_NEWSIZE'  => {
      line  => "HEAP_NEWSIZE='${heap_new_size}M'",
      match => '#HEAP_NEWSIZE="800M"',
    }
  }
}
