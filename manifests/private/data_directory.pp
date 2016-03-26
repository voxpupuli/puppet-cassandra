# cassandra::private::data_directory
define cassandra::private::data_directory( $directory_name = $title, ) {
  if ! defined( File[$directory_name] ) {
    file { $directory_name:
      ensure  => directory,
      owner   => 'cassandra',
      group   => 'cassandra',
      mode    => $::cassandra::data_file_directories_mode,
      require => Package[$::cassandra::cassandra_pkg],
    }
  }
}
