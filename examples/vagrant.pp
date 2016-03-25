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

$keyspaces = {
  'Excelsior' => {
    ensure          => present,
    replication_map => {
      keyspace_class     => 'SimpleStrategy',
      replication_factor => 3,
    },
    durable_writes  => false,
  },
  'Excalibur' => {
    ensure          => present,
    replication_map => {
      keyspace_class => 'NetworkTopologyStrategy',
      dc1            => 3,
      dc2            => 2,
    },
    durable_writes  => true,
  },
}

$cql_types = {
  'fullname' => {
    'keyspace' => 'Excalibur',
    'fields'   => {
      'firstname' => 'text',
      'lastname'  => 'text',
    },
  },
  'address'  => {
    'keyspace' => 'Excalibur',
    'fields'   => {
      'street'   => 'text',
      'city'     => 'text',
      'zip_code' => 'int',
      'phones'   => 'set<text>',
    },
  },
}

class { 'cassandra::schema':
  keyspaces => $keyspaces,
  cql_types => $cql_types,
}
