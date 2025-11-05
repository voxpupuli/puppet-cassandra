# @summary Class to manage database schema resources.
#   Please note that cqlsh expects Python to be installed.
#
# @param connection_tries
#   How many times to try a connection to Cassandra. Also see `connection_try_sleep`.
# @param connection_try_sleep
#   How much time to allow between the number of tries specified in `connection_tries`.
# @param cqlsh_additional_options
#   Any additional options to be passed to the `cqlsh` command.
# @param cqlsh_client_config
#   Set this to a file name (e.g. '/root/.puppetcqlshrc')
#   This will contain the credentials for connecting to Cassandra.
# @param cqlsh_client_tmpl
#   The location of the template for configuring the credentials for the cqlsh client.
# @param cqlsh_command
#   The full path to the `cqlsh` command.
# @param cqlsh_host
#   The host for the `cqlsh` command to connect to.
# @param cqlsh_port
#   The port for the `cqlsh` command to connect to.
# @param cqlsh_user
#   The user for the cqlsh connection.
# @param cqlsh_password
#   The password for the cqlsh connection.
# @param cql_types
#   Creates new `cassandra::schema::cql_type` resources.
# @param indexes
#   Creates new `cassandra::schema::index` resources.
# @param keyspaces
#   Creates new `cassandra::schema::keyspace` resources.
# @param permissions
#   Creates new `cassandra::schema::permission` resources.
# @param tables
#   Creates new `cassandra::schema::table` resources.
# @param users
#   Creates new `cassandra::schema::user` resources.
#
class cassandra::schema (
  Integer $connection_tries = 6,
  Integer $connection_try_sleep = 30,
  Optional[String[1]] $cqlsh_additional_options = undef,
  Optional[Stdlib::Absolutepath] $cqlsh_client_config = undef,
  String[1] $cqlsh_client_tmpl = 'cassandra/cqlshrc.erb',
  Stdlib::Absolutepath $cqlsh_command = '/usr/bin/cqlsh',
  Variant[Stdlib::Host, Enum['localhost']] $cqlsh_host = 'localhost',
  Integer $cqlsh_port = 9042,
  String[1] $cqlsh_user = 'cassandra',
  Optional[Variant[String[1], Sensitive]] $cqlsh_password = undef,
  Hash $cql_types = {},
  Hash $indexes = {},
  Hash $keyspaces = {},
  Hash $permissions = {},
  Hash $tables = {},
  Hash $users = {},
) {
  require cassandra

  if $cqlsh_client_config {
    file { $cqlsh_client_config :
      ensure  => file,
      group   => $facts['identity']['gid'],
      mode    => '0600',
      owner   => $facts['identity']['uid'],
      content => template($cqlsh_client_tmpl),
      before  => Exec['cassandra::schema connection test'],
    }

    $cmdline_login = "--cqlshrc=${cqlsh_client_config}"
  } else {
    if $cqlsh_password {
      warning('You may want to consider using the cqlsh_client_config attribute')
      $cmdline_login = "-u ${cqlsh_user} -p ${cqlsh_password}"
    } else {
      $cmdline_login = ''
    }
  }

  $cqlsh_opts = "${cqlsh_command} ${cmdline_login} ${cqlsh_additional_options}"
  $cqlsh_conn = "${cqlsh_host} ${cqlsh_port}"

  $connection_test = "${cqlsh_opts} -e 'DESC KEYSPACES' ${cqlsh_conn}"

  exec { 'cassandra::schema connection test':
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
  if $cql_types {
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

  # manage permissions if present
  if $permissions {
    create_resources('cassandra::schema::permission', $permissions)
  }

  # Resource Ordering
  Cassandra::Schema::Keyspace <| |> -> Cassandra::Schema::Cql_type <| |>
  Cassandra::Schema::Keyspace <| |> -> Cassandra::Schema::Table <| |>
  Cassandra::Schema::Keyspace <| |> -> Cassandra::Schema::Permission <| |>
  Cassandra::Schema::Cql_type <| |> -> Cassandra::Schema::Table <| |>
  Cassandra::Schema::Table <| |> -> Cassandra::Schema::Index <| |>
  Cassandra::Schema::Table <| |> -> Cassandra::Schema::Permission <| |>
  Cassandra::Schema::Index <| |> -> Cassandra::Schema::User <| |>
  Cassandra::Schema::User <| |> -> Cassandra::Schema::Permission <| |>
}
