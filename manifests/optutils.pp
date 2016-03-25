# Please see the README file for the module.
class cassandra::optutils (
  $ensure         = 'present',
  $package_ensure = 'present',
  $package_name   = $::cassandra::params::optutils_package_name,
  ) inherits cassandra::params {
  # Some horrific jiggerypokery until we can deprecate the ensure parameter.
  if $ensure != present {
    if $package_ensure != present and $ensure != $package_ensure {
      fail('Both ensure and package_ensure attributes are set.')
    }

    cassandra::private::deprecation_warning { 'cassandra::optutils::ensure':
      item_number => 16,
    }

    $version = $ensure
  } else {
    $version = $package_ensure
  }

  package { $package_name:
    ensure  => $version,
    require => Class['cassandra'],
  }
}
