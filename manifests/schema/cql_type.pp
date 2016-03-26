# cassandra::schema::cql_type
define cassandra::schema::cql_type (
  $keyspace,
  $ensure = 'present',
  $fields = {},
  $cql_type_name = $title,
  ){
  include 'cassandra::schema'
  $read_script = "DESC TYPE ${keyspace}.${cql_type_name}"
  $read_command = "${::cassandra::schema::cqlsh_opts} -e \"${read_script}\" ${::cassandra::schema::cqlsh_conn}"

  if $ensure == present {
    $create_script1 = "CREATE TYPE IF NOT EXISTS ${keyspace}.${cql_type_name}"
    $create_script2 = join(join_keys_to_values($fields, ' '), ', ')
    $create_script = "${create_script1} (${create_script2})"
    $create_command = "${::cassandra::schema::cqlsh_opts} -e \"${create_script}\" ${::cassandra::schema::cqlsh_conn}"
    exec { $create_command:
      unless  => $read_command,
      require => Exec['::cassandra::schema connection test'],
    }
  } elsif $ensure == absent {
    $delete_script = "DROP type ${keyspace}.${cql_type_name}"
    $delete_command = "${::cassandra::schema::cqlsh_opts} -e \"${delete_script}\" ${::cassandra::schema::cqlsh_conn}"
    exec { $delete_command:
      onlyif  => $read_command,
      require => Exec['::cassandra::schema connection test'],
    }
  } else {
    fail("Unknown action (${ensure}) for ensure attribute.")
  }
}
