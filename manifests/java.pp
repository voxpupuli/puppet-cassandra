# Please see the README file for the module.
class cassandra::java (
  $ensure           = 'present',
  $jna_ensure       = 'present',
  $jna_package_name = $::cassandra::params::jna_package_name,
  $package_ensure   = 'present',
  $package_name     = $::cassandra::params::java_package,
  ) inherits cassandra::params {
  # Some horrific jiggerypokery until we can deprecate the ensure parameter.
  if $ensure != present {
    if $package_ensure != present and $ensure != $package_ensure {
      fail('Both ensure and package_ensure attributes are set.')
    }

    cassandra::private::deprecation_warning { 'cassandra::java::ensure':
      item_number => 16,
    }

    $version = $ensure
  } else {
    $version = $package_ensure
  }
  
  if $::osfamily == 'Debian' {
    file_line { 'Adding installation sources for OpenJDK 8':
      path   => '/etc/apt/sources.list',
      line   => "deb http://http.debian.net/debian ${::lsbdistcodename}-backports main",
      before => Package[$package_name],
    } ~>
    exec { 'cassandra::java::apt_update':
      refreshonly => true,
      command     => '/bin/true',
      require     => Exec['apt_update'],
    }
  }

  package { $package_name:
    ensure => $version,
  }

  package { $jna_package_name:
    ensure => $jna_ensure,
  }
}
