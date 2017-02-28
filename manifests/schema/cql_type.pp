# Create or drop user defined data types within the schema.
# @param keyspace [string] The name of the keyspace that the data type is to be associated with.
# @param ensure [present|absent] ensure the data type is created, or is dropped.
# @param fields [hash] A hash of the fields that will be components for the data type.
# @param cql_type_name [string] The name of the CQL type to be created.
# @example
#   cassandra::schema::cql_type { 'fullname':
#     keyspace => 'mykeyspace',
#     fields   => {
#       'fname' => 'text',
#       'lname' => 'text',
#     },
#   }
define cassandra::schema::cql_type (
  $keyspace,
  $ensure = present,
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
