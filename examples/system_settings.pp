# Cassandra pre-requisites
require cassandra::apache_repo

if $sysctl_args {
  class { 'cassandra::system::sysctl':
    sysctl_args => $sysctl_args,
  }
} else {
  require cassandra::system::sysctl
}
