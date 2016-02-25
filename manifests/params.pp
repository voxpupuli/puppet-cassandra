# == Class cassandra::params
#
# This class is meant to be called from cassandra
# It sets variables according to platform
#
class cassandra::params {
  if $::osfamily == 'Debian' {
    $systemctl = '/bin/systemctl'
  } elsif $::osfamily == 'RedHat' {
    $systemctl = '/usr/bin/systemctl'
  }
}
