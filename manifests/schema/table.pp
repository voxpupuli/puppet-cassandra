# @summary A defined type to create or drop a table.
#
# @example Basic usage.
#   cassandra::schema::table { 'users':
#     keyspace => 'mykeyspace',
#     columns  => {
#       'userid'      => 'int',
#       'fname'       => 'text',
#       'lname'       => 'text',
#       'PRIMARY KEY' => '(userid)',
#     },
#   }
#
# @param keyspace
#   The name of the keyspace.
# @param ensure
#   Ensure the index is created or dropped.
# @param columns
#   A hash of the columns to be placed in the table. Optional if the table is to be absent.
# @param options
#   Options to be added with table creation.
# @param table
#   The name of the table.
#
define cassandra::schema::table (
  String[1] $keyspace,
  Enum['present', 'absent'] $ensure = present,
  Hash $columns = {},
  Array $options = [],
  String[1] $table = $title,
) {
  require cassandra::schema

  $quote = '"'
  $read_script = "DESC TABLE ${keyspace}.${table}"
  $read_command = "${cassandra::schema::cqlsh_opts} -e ${quote}${read_script}${quote} ${cassandra::schema::cqlsh_conn}"

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

    $create_command = "${cassandra::schema::cqlsh_opts} -e ${quote}${create_script}${quote} ${cassandra::schema::cqlsh_conn}"
    exec { $create_command:
      unless  => $read_command,
      require => Exec['cassandra::schema connection test'],
    }
  } else {
    $delete_script = "DROP TABLE IF EXISTS ${keyspace}.${table}"
    $delete_command = "${cassandra::schema::cqlsh_opts} -e ${quote}${delete_script}${quote} ${cassandra::schema::cqlsh_conn}"
    exec { $delete_command:
      onlyif  => $read_command,
      require => Exec['cassandra::schema connection test'],
    }
  }
}
