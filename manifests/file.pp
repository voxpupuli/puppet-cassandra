# cassandra::file
define cassandra::file(
  $file             = $title,
  $config_path      = $::cassandra::config_path,
  $file_lines       = undef,
  $service_refresh  = true,
  ) {
  include cassandra
  include cassandra::params
  include stdlib

  $path = "${config_path}/${file}"

  if $file_lines != undef {
    if $service_refresh {
      $default_file_line = {
        path    => $path,
        require => Package['cassandra'],
        notify  => Service['cassandra'],
      }
    } else {
      $default_file_line = {
        path    => $path,
        require => Package['cassandra'],
      }
    }

    create_resources(file_line, $file_lines, $default_file_line)
  }
}
