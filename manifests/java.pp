# Please see the README file for the module.
class cassandra::java (
  $ensure           = 'present',
  $jna_ensure       = 'present',
  $jna_package_name = undef,
  $package_ensure   = 'present',
  $package_name     = undef,
  ) {
  if $package_name == undef {
    if $::osfamily == 'RedHat' {
      $java_package_name = 'java-1.8.0-openjdk-headless'
    } elsif $::osfamily == 'Debian' {
      $java_package_name = 'openjdk-7-jre-headless'
    } else {
      fail("OS family ${::osfamily} not supported")
    }
  } else {
    $java_package_name = $package_name
  }

  if $jna_package_name == undef {
    if $::osfamily == 'RedHat' {
      $jna = 'jna'
    } elsif $::osfamily == 'Debian' {
      $jna = 'libjna-java'
    } else {
      fail("OS family ${::osfamily} not supported")
    }
  } else {
    $jna = $jna_package_name
  }

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

  package { $java_package_name:
    ensure => $version,
  }

  package { $jna:
    ensure => $jna_ensure,
  }
}
