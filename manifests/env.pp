# cassandra::env
class cassandra::env(
  $environment_file = $::cassandra::params::environment_file,
  $file_lines       = undef,
  $service_refresh  = true,
  ) inherits cassandra::params {
  include cassandra
  include stdlib

  if $file_lines != undef {
    if $service_refresh {
      $default_file_line = {
        path    => $environment_file,
        require => Package['cassandra'],
        notify  => Service['cassandra'],
      }
    } else {
      $default_file_line = {
        path    => $environment_file,
        require => Package['cassandra'],
      }
    }

    create_resources(file_line, $file_lines, $default_file_line)
  }
}
