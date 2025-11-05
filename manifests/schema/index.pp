# @summary A defined type to create or drop an index.
#
# @param keyspace
#   The name of the keyspace that the data type is to be associated with.
# @param table
#   The name of the table that the index is to be associated with.
# @param ensure
#   Ensure the index is created or dropped.
# @param class_name
#   The name of the class to be associated with an index when creating a custom index.
# @param index
#   The name of the index.
# @param keys
#   The columns that the index is being created on.
# @param options
#   Any options to be added to the index.
#
define cassandra::schema::index (
  String[1] $keyspace,
  String[1] $table,
  Enum['present', 'absent'] $ensure = present,
  Optional[String[1]] $class_name = undef,
  String[1] $index = $title,
  Optional[String[1]] $keys = undef,
  Optional[String[1]] $options = undef,
) {
  require cassandra::schema

  $quote = '"'
  # Fully qualified index name.
  $fqin = "${keyspace}.${index}"
  # Fully qualified table name.
  $fqtn = "${keyspace}.${table}"

  $read_script = "DESC INDEX ${fqin}"
  $read_command = "${cassandra::schema::cqlsh_opts} -e ${quote}${read_script}${quote} ${cassandra::schema::cqlsh_conn}"

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

    $create_command = "${cassandra::schema::cqlsh_opts} -e ${quote}${create_script}${quote} ${cassandra::schema::cqlsh_conn}"

    exec { $create_command:
      unless  => $read_command,
      require => Exec['cassandra::schema connection test'],
    }
  } else {
    $delete_script = "DROP INDEX ${fqin}"
    $delete_command = "${cassandra::schema::cqlsh_opts} -e ${quote}${delete_script}${quote} ${cassandra::schema::cqlsh_conn}"
    exec { $delete_command:
      onlyif  => $read_command,
      require => Exec['cassandra::schema connection test'],
    }
  }
}
