# cassandra::schema::table
define cassandra::schema::table (
  $keyspace,
  $ensure  = present,
  $columns = {},
  $options = [],
  $table   = $title,
  ){
  include 'cassandra::schema'
  $read_script = "DESC TABLE ${keyspace}.${table}"
  $read_command = "${::cassandra::schema::cqlsh_opts} -e \"${read_script}\" ${::cassandra::schema::cqlsh_conn}"

  if $ensure == present {
    $create_script1 = "CREATE TABLE IF NOT EXISTS ${keyspace}.${table}"
    $cols_def = join(join_keys_to_values($columns, ' '), ', ')
    $cols_def_rm_collection_type = delete($cols_def, 'COLLECTION-TYPE ')

    if count($options) > 0 {
      $options_def = join($options, ' AND ')
      $create_script = "${create_script1} (${cols_def_rm_collection_type}) WITH ${options_def}"
    } else {
      $create_script = "${create_script1} (${cols_def_rm_collection_type})"
    }

    $create_command = "${::cassandra::schema::cqlsh_opts} -e \"${create_script}\" ${::cassandra::schema::cqlsh_conn}"
    exec { $create_command:
      unless  => $read_command,
      require => Exec['::cassandra::schema connection test'],
    }
  } elsif $ensure == absent {
    $delete_script = "DROP TABLE IF EXISTS ${keyspace}.${table}"
    $delete_command = "${::cassandra::schema::cqlsh_opts} -e \"${delete_script}\" ${::cassandra::schema::cqlsh_conn}"
    exec { $delete_command:
      onlyif  => $read_command,
      require => Exec['::cassandra::schema connection test']
    }
  } else {
    fail("Unknown action (${ensure}) for ensure attribute.")
  }
}
