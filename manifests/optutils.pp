# Please see the README file for the module.
class cassandra::optutils (
  $package_ensure = 'present',
  $package_name   = $::cassandra::params::optutils_package_name,
  ) inherits cassandra::params {
  package { $package_name:
    ensure  => $package_ensure,
    require => Class['cassandra'],
  }
}
