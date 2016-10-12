# Please see the README file for the module.
class cassandra::java (
  $aptkey           = undef,
  $aptsource        = undef,
  $jna_ensure       = 'present',
  $jna_package_name = $::cassandra::params::jna_package_name,
  $package_ensure   = 'present',
  $package_name     = $::cassandra::params::java_package,
  $temp_directory   = undef,
  $yumrepo          = undef,
  ) inherits cassandra::params {
  if $::osfamily == 'RedHat' and $yumrepo != undef {
    $yumrepo_defaults = {
      'before' => Package[$package_name],
    }

    create_resources(yumrepo, $yumrepo, $yumrepo_defaults)
  }

  if $::osfamily == 'Debian' {
    if $aptkey != undef {
      $aptkey_defaults = {
        'before' => Package[$package_name],
      }

      create_resources(apt::key, $aptkey, $aptkey_defaults)
    }

    if $aptsource != undef {
      exec { 'cassandra::java::apt_update':
        refreshonly => true,
        command     => '/bin/true',
        require     => Exec['apt_update'],
        before      => Package[$package_name],
      }

      $aptsource_defaults = {
        'notify' => Exec['cassandra::java::apt_update'],
      }

      create_resources(apt::source, $aptsource, $aptsource_defaults)
    }
  }

  package { $package_name:
    ensure => $package_ensure,
  }

  package { $jna_package_name:
    ensure => $jna_ensure,
  }

  if $temp_directory != undef {
    file { $temp_directory:
      ensure => 'directory',
      owner  => 'cassandra',
      group  => 'cassandra',
      mode   => '0750',
    }
    file_line { "Setting java temp directory to ${temp_directory}":
      path    => '/etc/cassandra/conf/jvm.options',
      line    => "-Djava.io.tmpdir=${temp_directory}",
      require => Package[$package_name]
    }
  }
}
