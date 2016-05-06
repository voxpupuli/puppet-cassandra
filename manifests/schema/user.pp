# cassandra::schema::user
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
