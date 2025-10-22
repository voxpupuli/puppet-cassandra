# @summary A defined type for altering files relative to the configuration directory.
#
# @example Set max_heap_size in cassandra-env.sh
#   cassandra::file { "Set Java/Cassandra max heap size to 500.":
#     file       => 'cassandra-env.sh',
#     file_lines => {
#       'MAX_HEAP_SIZE' => {
#         line  => 'MAX_HEAP_SIZE=500M',
#         match => '^#?MAX_HEAP_SIZE=.*',
#       },
#     }
#   }
#
# @example Set heap_newsize in cassandra-env.sh
#   cassandra::file { "Set Java/Cassandra heap new size to 300.":
#     file       => 'cassandra-env.sh',
#     file_lines => {
#       'HEAP_NEWSIZE'  => {
#         line  => 'HEAP_NEWSIZE=300M',
#         match => '^#?HEAP_NEWSIZE=.*',
#       }
#     }
#   }
#
# @example Set java.io.tmpdir in jvm.options
#   cassandra::file { 'Set java.io.tmpdir':
#     file       => 'jvm.options',
#     file_lines => {
#       'java.io.tmpdir' => {
#         line => '-Djava.io.tmpdir=/var/lib/cassandra/tmp',
#       },
#     },
#   }
#
# @param file_lines
#   will be used to create an array of [file_line]
# @param file
#   Name of the file relative to `cassandra::config_path`.
#
define cassandra::file (
  Hash $file_lines,
  String[1] $file = $title,
) {
  include cassandra

  $_notify = $cassandra::service_refresh ? {
    true    => Service[$cassandra::service_name],
    default => undef,
  }

  $file_lines.each | String $_line, Hash $_params | {
    file_line { $_line:
      *      => $_params,
      path   => "${$cassandra::config_path}/${file}" ,
      notify => $_notify,
    }
  }
}
