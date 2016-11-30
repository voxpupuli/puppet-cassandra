# Grant or revoke permissions.
# To use this class, a suitable `authenticator` (e.g. PasswordAuthenticator)
# and `authorizer` (e.g. CassandraAuthorizer) must be set in the Cassandra
# class.
#
# WARNING: Specifying keyspace 'ALL' and 'ALL' for permissions at the same
# time is not currently supported by this module.
#
# @param user_name [string] The name of the user who is to be granted or
#   revoked.
# @param ensure [ present | absent ] Set to present to grant a permission or
#   absent to revoke it.
# @param keyspace_name [string] The name of the keyspace to grant/revoke the
#   permissions on.  If set to 'ALL' then the permission will be applied to
#   all of the keyspaces.
# @param permission_name [string] Can be one of the following:
#
#   * 'ALTER' - ALTER KEYSPACE, ALTER TABLE, CREATE INDEX, DROP INDEX.
#   * 'AUTHORIZE' - GRANT, REVOKE.
#   * 'CREATE' - CREATE KEYSPACE, CREATE TABLE.
#   * 'DROP' - DROP KEYSPACE, DROP TABLE.
#   * 'MODIFY' - INSERT, DELETE, UPDATE, TRUNCATE.
#   * 'SELECT' - SELECT.
#
#   If the permission_name is set to 'ALL', this will set all of the specific
#   permissions listed.
# @param table_name [string] The name of a table within the specified
#   keyspace.  If left unspecified, the procedure will be applied to all
#   tables within the keyspace.
define cassandra::schema::permission (
  $user_name,
  $ensure           = present,
  $keyspace_name    = 'ALL',
  $permission_name  = 'ALL',
  $table_name       = undef,
  ){
  include 'cassandra::schema'

  if upcase($keyspace_name) == 'ALL' and upcase($permission_name) == 'ALL' {
    fail('"ALL" keyspaces AND "ALL" permissions are mutually exclusive.')
  } elsif $table_name {
    $resource = "TABLE ${keyspace_name}.${table_name}"
  } elsif upcase($keyspace_name) == 'ALL' {
    $resource = 'ALL KEYSPACES'
  } else {
    $resource = "KEYSPACE ${keyspace_name}"
  }

  $read_script = "LIST ALL PERMISSIONS ON ${resource}"
  $upcase_permission_name = upcase($permission_name)
  $pattern = "\s${user_name} |\s*${user_name} |\s.*\s${upcase_permission_name}$"
  $read_command = "${::cassandra::schema::cqlsh_opts} -e \"${read_script}\" ${::cassandra::schema::cqlsh_conn} | grep '${pattern}'"

  if upcase($permission_name) == 'ALL' {
    cassandra::schema::permission { "${title} - ALTER":
      ensure          => $ensure,
      user_name       => $user_name,
      keyspace_name   => $keyspace_name,
      permission_name => 'ALTER',
      table_name      => $table_name,
    }

    cassandra::schema::permission { "${title} - AUTHORIZE":
      ensure          => $ensure,
      user_name       => $user_name,
      keyspace_name   => $keyspace_name,
      permission_name => 'AUTHORIZE',
      table_name      => $table_name,
    }

    # The CREATE permission is not relevant to tables.
    if !$table_name {
      cassandra::schema::permission { "${title} - CREATE":
        ensure          => $ensure,
        user_name       => $user_name,
        keyspace_name   => $keyspace_name,
        permission_name => 'CREATE',
        table_name      => $table_name,
      }
    }

    cassandra::schema::permission { "${title} - DROP":
      ensure          => $ensure,
      user_name       => $user_name,
      keyspace_name   => $keyspace_name,
      permission_name => 'DROP',
      table_name      => $table_name,
    }

    cassandra::schema::permission { "${title} - MODIFY":
      ensure          => $ensure,
      user_name       => $user_name,
      keyspace_name   => $keyspace_name,
      permission_name => 'MODIFY',
      table_name      => $table_name,
    }

    cassandra::schema::permission { "${title} - SELECT":
      ensure          => $ensure,
      user_name       => $user_name,
      keyspace_name   => $keyspace_name,
      permission_name => 'SELECT',
      table_name      => $table_name,
    }
  } elsif $ensure == present {
    $create_script = "GRANT ${permission_name} ON ${resource} TO ${user_name}"
    $create_command = "${::cassandra::schema::cqlsh_opts} -e \"${create_script}\" ${::cassandra::schema::cqlsh_conn
}"

    exec { $create_script:
      command => $create_command,
      unless  => $read_command,
      require => Exec['::cassandra::schema connection test'],
    }
  } elsif $ensure == absent {
    $delete_script = "REVOKE ${permission_name} ON ${resource} FROM ${user_name}"
    $delete_command = "${::cassandra::schema::cqlsh_opts} -e \"${delete_script}\" ${::cassandra::schema::cqlsh_conn}"

    exec { $delete_script:
      command => $delete_command,
      onlyif  => $read_command,
      require => Exec['::cassandra::schema connection test'],
    }
  } else {
    fail("Unknown action (${ensure}) for ensure attribute.")
  }
}
