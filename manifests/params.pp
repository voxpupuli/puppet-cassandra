# This class is meant to be called from cassandra.
# It sets variables according to platform
#
# Variables
# ---------
# * `$::cassandra::params::cassandra_pkg`
# defaults to 'cassandra' on Debian and 'cassandra22' on Red Hat.
# * `$::cassandra::params::config_path`
# defaults to '/etc/cassandra' on Debian and '/etc/cassandra/default.conf' on Red Hat.
# * `$::cassandra::params::java_package`
# defaults to 'openjdk-7-jre-headless' on Debian and 'java-1.8.0-openjdk-headless' on Red Hat.
# * `$::cassandra::params::jna_package_name`
# defaults to 'libjna-java' on Debian and 'jna' on Red Hat.
# * `$::cassandra::params::optutils_package_name`
# defaults to 'cassandra-tools' on Debian and 'cassandra22-tools' on Red Hat.
# * `$::cassandra::params::systemctl`
# defaults to '/bin/systemctl' on Debian and '/usr/bin/systemctl' on Red Hat.
class cassandra::params {
  case $::osfamily {
    'Debian': {
      $cassandra_pkg = 'cassandra'
      $config_path = '/etc/cassandra'
      $java_package = 'openjdk-7-jre-headless'
      $jna_package_name = 'libjna-java'
      $optutils_package_name = 'cassandra-tools'
      $systemctl = '/bin/systemctl'
    }
    'RedHat': {
      $cassandra_pkg = 'cassandra22'
      $config_path = '/etc/cassandra/default.conf'
      $java_package = 'java-1.8.0-openjdk-headless'
      $jna_package_name = 'jna'
      $optutils_package_name = 'cassandra22-tools'
      $systemctl = '/usr/bin/systemctl'
    }
    default: {
      $config_path_parents = []
    }
  }
}
