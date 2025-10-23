# @summary A defined type to create or drop a keyspace.
#
# @example Basic usage.
#   cassandra::schema::keyspace { 'mykeyspace':
#     replication_map => {
#       keyspace_class     => 'SimpleStrategy',
#       replication_factor => 1,
#     },
#     durable_writes  => false,
#   }
#
# @param ensure
#   Ensure the index is created or dropped.
# @param durable_writes
#   When set to false, data written to the keyspace bypasses the commit log.
#   Be careful using this option because you risk losing data.
#   Set this attribute to false on a keyspace using the SimpleStrategy.
# @param keyspace_name
#   The name of the keyspace to be created.
# @param replication_map
#   Needed if the keyspace is to be present. Optional if it is to be absent.
#
define cassandra::schema::keyspace (
  Enum['present', 'absent'] $ensure = present,
  Boolean $durable_writes = true,
  String[1] $keyspace_name = $title,
  Hash $replication_map = {},
) {
  require cassandra::schema

  $quote = '"'
  $read_script = "DESC KEYSPACE ${keyspace_name}"
  $read_command = "${cassandra::schema::cqlsh_opts} -e ${quote}${read_script}${quote} ${cassandra::schema::cqlsh_conn}"

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
    $create_command = "${cassandra::schema::cqlsh_opts} -e ${quote}${create_script}${quote} ${cassandra::schema::cqlsh_conn}"
    exec { $create_command:
      unless  => $read_command,
      require => Exec['cassandra::schema connection test'],
    }
  } else {
    $delete_script = "DROP KEYSPACE ${keyspace_name}"
    $delete_command = "${cassandra::schema::cqlsh_opts} -e ${quote}${delete_script}${quote} ${cassandra::schema::cqlsh_conn}"
    exec { $delete_command:
      onlyif  => $read_command,
      require => Exec['cassandra::schema connection test'],
    }
  }
}
