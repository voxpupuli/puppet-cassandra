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
    $deb_major_release = $::os['release']['major']
    if $deb_major_release == '8' { $deb_release_name = 'jessie' }
    if $deb_major_release == '7' { $deb_release_name = 'wheezy' }
    if $deb_major_release == '6' { $deb_release_name = 'squeeze' }
    file_line { 'Adding installation sources for OpenJDK 8':
      path  => '/etc/apt/sources.list',
      line => "deb http://http.debian.net/debian $deb_release_name-backports main",
    }
    # This is horrible.
    # See here: http://backports.debian.org/Instructions/#index3h2
    # tl;dr - apt will not automatically install backports in debian
    exec { 'Install Cassandra from backports':
      path    => '/usr/sbin',
      command => "apt-get -t $deb_release_name-backports install $package_name",
    }
  }

  package { $package_name:
    ensure => $version,
  }

  package { $jna_package_name:
    ensure => $jna_ensure,
  }
}
