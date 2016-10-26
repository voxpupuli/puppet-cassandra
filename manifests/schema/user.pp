# Create or drop users.
# To use this class, a suitable `authenticator` (e.g. PasswordAuthenticator)
# must be set in the Cassandra class.
# @param ensure [ present | absent ] Valid values can be **present** to
#   ensure a user is created, or **absent** to remove the user if it exists.
# @param password [string] A password for the user.
# @param superuser [boolean] If the user is to be a super-user on the system.
# @param user_name [string] The name of the user.
# @example
#   cassandra::schema::user { 'akers':
#     password  => 'Niner2',
#     superuser => true,
#   }
#
#   cassandra::schema::user { 'lucan':
#     ensure => absent,
#   }
define cassandra::schema::user (
  $ensure    = present,
  $password  = undef,
  $superuser = false,
  $user_name = $title,
  ){
  include 'cassandra::schema'
  $read_script = 'LIST USERS'
  $read_command = "${::cassandra::schema::cqlsh_opts} -e \"${read_script}\" ${::cassandra::schema::cqlsh_conn} | grep '\s*${user_name} |'"

  if $ensure == present {
    $create_script1 = "CREATE USER IF NOT EXISTS ${user_name}"

    if $password != undef {
      $create_script2 = "${create_script1} WITH PASSWORD '${password}'"
    } else {
      $create_script2 = $create_script1
    }

    if $superuser {
      $create_script = "${create_script2} SUPERUSER"
    } else {
      $create_script = "${create_script2} NOSUPERUSER"
    }

    $create_command = "${::cassandra::schema::cqlsh_opts} -e \"${create_script}\" ${::cassandra::schema::cqlsh_conn}"

    exec { "Create user (${user_name})":
      command => $create_command,
      unless  => $read_command,
      require => Exec['::cassandra::schema connection test'],
    }
  } elsif $ensure == absent {
    $delete_script = "DROP USER ${user_name}"
    $delete_command = "${::cassandra::schema::cqlsh_opts} -e \"${delete_script}\" ${::cassandra::schema::cqlsh_conn}"

    exec { "Delete user (${user_name})":
      command => $delete_command,
      onlyif  => $read_command,
      require => Exec['::cassandra::schema connection test'],
    }
  } else {
    fail("Unknown action (${ensure}) for ensure attribute.")
  }
}
