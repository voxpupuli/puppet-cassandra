# cassandra::schema::index
define cassandra::schema::index(
  $keyspace,
  $table,
  $class_name = undef,
  $ensure     = present,
  $index      = $title,
  $keys       = undef,
  $options    = undef,
  ) {
  include 'cassandra::schema'

  # Fully qualified index name.
  $fqin = "${keyspace}.${index}"
  # Fully qualified table name.
  $fqtn = "${keyspace}.${table}"

  $read_script = "DESC INDEX ${fqin}"
  $read_command = "${::cassandra::schema::cqlsh_opts} -e \"${read_script}\" ${::cassandra::schema::cqlsh_conn}"

  if $ensure == present {
    if $class_name != undef {
      $create_part1 = "CREATE CUSTOM INDEX IF NOT EXISTS ${index} ON ${keyspace}.${table}"
    } else {
      $create_part1 = "CREATE INDEX IF NOT EXISTS ${index} ON ${keyspace}.${table}"
    }

    if $class_name != undef {
      $create_part2 = "${create_part1} (${keys}) USING '${class_name}'"
    } else {
      $create_part2 = "${create_part1} (${keys})"
    }

    if $options != undef {
      $create_script = "${create_part2} WITH OPTIONS = ${options}"
    } else {
      $create_script = $create_part2
    }

    $create_command = "${::cassandra::schema::cqlsh_opts} -e \"${create_script}\" ${::cassandra::schema::cqlsh_conn}"

    exec { $create_command:
      unless  => $read_command,
      require => Exec['::cassandra::schema connection test'],
    }
  } elsif $ensure == absent {
    $delete_script = "DROP INDEX ${fqin}"
    $delete_command = "${::cassandra::schema::cqlsh_opts} -e \"${delete_script}\" ${::cassandra::schema::cqlsh_conn}"
    exec { $delete_command:
      onlyif  => $read_command,
      require => Exec['::cassandra::schema connection test'],
    }
  } else {
    fail("Unknown action (${ensure}) for ensure attribute.")
  }
}

