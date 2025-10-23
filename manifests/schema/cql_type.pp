# @summary A defined type to create or drop a user defined data type.
#
# @example Basic usage.
#   cassandra::schema::cql_type { 'fullname':
#     keyspace => 'mykeyspace',
#     fields   => {
#       'fname' => 'text',
#       'lname' => 'text',
#     },
#   }
#
# @param keyspace
#   The name of the keyspace that the data type is to be associated with.
# @param ensure
#   Ensure the data type is created or dropped.
# @param fields
#   A hash of fields that will be components for the data type.
# @param cql_type_name
#   The name of the CQL type to be created.
#
define cassandra::schema::cql_type (
  String[1] $keyspace,
  Enum['present', 'absent'] $ensure = present,
  Hash $fields = {},
  String[1] $cql_type_name = $title,
) {
  require cassandra::schema

  $quote = '"'
  $read_script = "DESC TYPE ${keyspace}.${cql_type_name}"
  $read_command = "${cassandra::schema::cqlsh_opts} -e ${quote}${read_script}${quote} ${cassandra::schema::cqlsh_conn}"

  if $ensure == present {
    $create_script1 = "CREATE TYPE IF NOT EXISTS ${keyspace}.${cql_type_name}"
    $create_script2 = join(join_keys_to_values($fields, ' '), ', ')
    $create_script = "${create_script1} (${create_script2})"
    $create_command = "${cassandra::schema::cqlsh_opts} -e ${quote}${create_script}${quote} ${cassandra::schema::cqlsh_conn}"
    exec { $create_command:
      unless  => $read_command,
      require => Exec['cassandra::schema connection test'],
    }
  } else {
    $delete_script = "DROP type ${keyspace}.${cql_type_name}"
    $delete_command = "${cassandra::schema::cqlsh_opts} -e ${quote}${delete_script}${quote} ${cassandra::schema::cqlsh_conn}"
    exec { $delete_command:
      onlyif  => $read_command,
      require => Exec['cassandra::schema connection test'],
    }
  }
}
