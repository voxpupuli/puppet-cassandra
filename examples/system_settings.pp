# Cassandra pre-requisites
require cassandra::apache_repo
require cassandra::system::transparent_hugepage

if $sysctl_args {
  class { 'cassandra::system::sysctl':
    sysctl_args => $sysctl_args,
  }
} else {
  require cassandra::system::sysctl
}
