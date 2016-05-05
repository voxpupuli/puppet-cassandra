# A class for maintaining DB schemas.
class cassandra::schema (
  $connection_tries         = 6,
  $connection_try_sleep     = 30,
  $cql_types                = {},
  $cqlsh_additional_options = '',
  $cqlsh_command            = '/usr/bin/cqlsh',
  $cqlsh_host               = $::cassandra::rpc_address,
  $cqlsh_password           = undef,
  $cqlsh_port               = $::cassandra::native_transport_port,
  $cqlsh_user               = 'cassandra',
  $cqlsh_client_tmpl        = 'cassandra/cqlshrc.erb',
  $cqlsh_client_config      = undef,
  $indexes                  = {},
  $keyspaces                = {},
  $tables                   = {},
  $users                    = {},
  ) inherits ::cassandra::params {
  require '::cassandra'

  if $cqlsh_client_config != undef {
    file { $cqlsh_client_config :
      ensure  => file,
      group   => $::gid,
      mode    => '0600',
      owner   => $::id,
      content => template( $cqlsh_client_tmpl ),
      before  => Exec['::cassandra::schema connection test'],
    }

    $cmdline_login = "--cqlshrc=${cqlsh_client_config}"
  } else {
    if $cqlsh_password != undef {
      warning('You may want to consider using the cqlsh_client_config attribute')
      $cmdline_login = "-u ${cqlsh_user} -p ${cqlsh_password}"
    } else {
      $cmdline_login = ''
    }
  }

  $cqlsh_opts = "${cqlsh_command} ${cmdline_login} ${cqlsh_additional_options}"
  $cqlsh_conn = "${cqlsh_host} ${cqlsh_port}"

  # See if we can make a connection to Cassandra.  Try $connection_tries
  # number of times with $connection_try_sleep in seconds between each try.
  $connection_test = "${cqlsh_opts} -e 'DESC KEYSPACES' ${cqlsh_conn}"
  exec { '::cassandra::schema connection test':
    command   => $connection_test,
    returns   => 0,
    tries     => $connection_tries,
    try_sleep => $connection_try_sleep,
    unless    => $connection_test,
  }

  # manage keyspaces if present
  if $keyspaces {
    create_resources('cassandra::schema::keyspace', $keyspaces)
  }

  # manage cql_types if present
  if $keyspaces {
    create_resources('cassandra::schema::cql_type', $cql_types)
  }

  # manage tables if present
  if $tables {
    create_resources('cassandra::schema::table', $tables)
  }

  # manage indexes if present
  if $indexes {
    create_resources('cassandra::schema::index', $indexes)
  }

  # manage users if present
  if $users {
    create_resources('cassandra::schema::user', $users)
  }

  # Resource Ordering
  Cassandra::Schema::Keyspace <| |> -> Cassandra::Schema::Cql_type <| |>
  Cassandra::Schema::Keyspace <| |> -> Cassandra::Schema::Table <| |>
  Cassandra::Schema::Cql_type <| |> -> Cassandra::Schema::Table <| |>
  Cassandra::Schema::Table <| |> -> Cassandra::Schema::Index <| |>
  Cassandra::Schema::Index <| |> -> Cassandra::Schema::User <| |>
}
