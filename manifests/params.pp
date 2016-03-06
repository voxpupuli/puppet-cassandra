# == Class cassandra::params
#
# This class is meant to be called from cassandra
# It sets variables according to platform
#
class cassandra::params {
  case $::osfamily {
    'Debian': {
      $optutils_package_name = 'cassandra-tools'
      $systemctl = '/bin/systemctl'
    }
    'RedHat': {
      $optutils_package_name = 'cassandra22-tools'
      $systemctl = '/usr/bin/systemctl'
    }
    default: {}
  }
}
