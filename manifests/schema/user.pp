# @summary A defined type to create or drop a user.
#
# @example Basic usage.
#   cassandra::schema::user { 'akers':
#     password  => 'Niner2',
#     superuser => true,
#   }
#
# @param ensure
#   Ensure the user is created or dropped.
# @param user_name
#   The name of the user.
# @param password
#   The password for the user.
# @param login
#   Allows the user to log in.
# @param superuser
#   Whether the user should be a super user.
#
define cassandra::schema::user (
  Enum['present', 'absent'] $ensure = present,
  String[1] $user_name = $title,
  Optional[Variant[String[1], Sensitive]] $password = undef,
  Boolean $login = true,
  Boolean $superuser = false,
) {
  require cassandra::schema

  $quote = '"'
  $read_script = 'LIST ROLES'
  $str_match = '\s'
  $read_command = "${cassandra::schema::cqlsh_opts} -e ${quote}${read_script}${quote} ${cassandra::schema::cqlsh_conn} | grep '${str_match}*${user_name} |'"

  if $ensure == present {
    $create_script1 = "CREATE ROLE IF NOT EXISTS ${user_name}"

    if $password != undef {
      $create_script2 = "${create_script1} WITH PASSWORD = '${password}'"
    } else {
      $create_script2 = $create_script1
    }

    if $superuser {
      if $password != undef {
        $create_script3 = "${create_script2} AND SUPERUSER = true"
      } else {
        $create_script3 = "${create_script2} WITH SUPERUSER = true"
      }
    } else {
      $create_script3 = $create_script2
    }

    if $login {
      if $superuser or $password != undef {
        $create_script = "${create_script3} AND LOGIN = true"
      }
      else {
        $create_script = "${create_script3} WITH LOGIN = true"
      }
    } else {
      $create_script = $create_script3
    }

    $create_command = "${cassandra::schema::cqlsh_opts} -e ${quote}${create_script}${quote} ${cassandra::schema::cqlsh_conn}"
    exec { "Create user (${user_name})":
      command => $create_command,
      unless  => $read_command,
      require => Exec['cassandra::schema connection test'],
    }
  } else {
    $delete_script = "DROP ROLE ${user_name}"
    $delete_command = "${cassandra::schema::cqlsh_opts} -e ${quote}${delete_script}${quote} ${cassandra::schema::cqlsh_conn}"
    exec { "Delete user (${user_name})":
      command => $delete_command,
      onlyif  => $read_command,
      require => Exec['cassandra::schema connection test'],
    }
  }
}
