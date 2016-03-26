# cassandra::schema::keyspace
define cassandra::schema::keyspace(
  $ensure          = present,
  $durable_writes  = true,
  $keyspace_name   = $title,
  $replication_map = {},
  ) {
  include 'cassandra::schema'

  $read_script = "DESC KEYSPACE ${keyspace_name}"
  $read_command = "${::cassandra::schema::cqlsh_opts} -e \"${read_script}\" ${::cassandra::schema::cqlsh_conn}"

  if $ensure == present {
    $keyspace_class = $replication_map[keyspace_class]

    case $keyspace_class {
      'SimpleStrategy': {
        $replication_factor = $replication_map[replication_factor]
        $map_str = "{ 'class' : 'SimpleStrategy', 'replication_factor' : ${replication_factor} }"
      }
      'NetworkTopologyStrategy': {
        $map_str1 = "{ 'class' : 'NetworkTopologyStrategy'"
        $new_map = prefix(delete($replication_map, 'keyspace_class'), "'")
        $map_str2 = join(join_keys_to_values($new_map, "': "), ', ')
        $map_str = "${map_str1}, ${map_str2} }"
      }
      default: {
        $msg_part1 = "Invalid or no class (${keyspace_class}) specified for"
        $msg_part2 = "keyspace ${keyspace_name}."
        fail("${msg_part1} ${msg_part2}")
      }
    }

    $create_script1 = "CREATE KEYSPACE IF NOT EXISTS ${keyspace_name}"
    $create_script2 = "WITH REPLICATION = ${map_str}"
    $create_script3 = "AND DURABLE_WRITES = ${durable_writes}"
    $create_script = "${create_script1} ${create_script2} ${create_script3}"
    $create_command = "${::cassandra::schema::cqlsh_opts} -e \"${create_script}\" ${::cassandra::schema::cqlsh_conn}"

    exec { $create_command:
      unless  => $read_command,
      require => Exec['::cassandra::schema connection test'],
    }
  } elsif $ensure == absent {
    $delete_script = "DROP KEYSPACE ${keyspace_name}"
    $delete_command = "${::cassandra::schema::cqlsh_opts} -e \"${delete_script}\" ${::cassandra::schema::cqlsh_conn}"
    exec { $delete_command:
      onlyif  => $read_command,
      require => Exec['::cassandra::schema connection test'],
    }
  } else {
    fail("Unknown action (${ensure}) for ensure attribute.")
  }
}
