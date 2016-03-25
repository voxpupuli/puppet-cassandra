if $::osfamily == 'RedHat' and $::operatingsystemmajrelease == 7 {
    $service_systemd = true
} elsif $::operatingsystem == 'Debian' and $::operatingsystemmajrelease == 8 {
    $service_systemd = true
} else {
    $service_systemd = false
}

if $::osfamily == 'RedHat' {
    $cassandra_optutils_package = 'cassandra22-tools'
    $cassandra_package = 'cassandra22'
    $version = '2.2.5-1'
} else {
    $cassandra_optutils_package = 'cassandra-tools'
    $cassandra_package = 'cassandra'
    $version = '2.2.5'
}

class { 'cassandra::java': } ->
class { 'cassandra::datastax_repo': } ->
class { 'cassandra':
  cassandra_9822              => true,
  commitlog_directory_mode    => '0770',
  data_file_directories_mode  => '0770',
  listen_interface            => 'lo',
  package_ensure              => $version,
  package_name                => $cassandra_package,
  rpc_interface               => 'lo',
  saved_caches_directory_mode => '0770',
  service_systemd             => $service_systemd,
}

class { 'cassandra::optutils':
  package_ensure => $version,
  package_name   => $cassandra_optutils_package,
  require        => Class['cassandra'],
}

class { 'cassandra::schema':
  cql_types => {
    'fullname' => {
      'keyspace' => 'Excalibur',
      'fields'   => {
        'firstname' => 'text',
        'lastname'  => 'text',
      }
    },
    'address'  => {
      'keyspace' => 'Excalibur',
      'fields'   => {
        'street'   => 'text',
        'city'     => 'text',
        'zip_code' => 'int',
        'phones'   => 'set<text>',
      }
    },
  },
  keyspaces => {
    'Excelsior' => {
      replication_map => {
        keyspace_class     => 'SimpleStrategy',
        replication_factor => 3,
      },
      durable_writes  => false,
    },
    'Excalibur' => {
      replication_map => {
        keyspace_class => 'NetworkTopologyStrategy',
        dc1            => 3,
        dc2            => 2,
      },
      durable_writes  => true,
    },
    'mykeyspace' => {
      replication_map => {
        keyspace_class => 'SimpleStrategy',
        replication_factor => 1,
      },
    },
  },
  tables    => {
    'users' => {
      'keyspace' => 'mykeyspace',
      'columns'       => {
        'userid'      => 'int',
        'fname'       => 'text',
        'lname'       => 'text',
        'PRIMARY KEY' => '(userid)',
      },
    },
    'users' => {
      'keyspace' => 'Excalibur',
      'columns'       => {
        'userid'          => 'text',
        'username'        => 'FROZEN<fullname>',
        'emails'          => 'set<text>',
        'top_scores'      => 'list<int>',
        'todo'            => 'map<timestamp, text>',
        'PRIMARY KEY'     => '(userid)',
      },
      'options'       => [
        "ID='5a1c395e-b41f-11e5-9f22-ba0be0483c18'"
      ],
    },
  },
}
