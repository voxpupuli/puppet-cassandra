# Cassandra pre-requisites
require cassandra::datastax_repo
require cassandra::system::transparent_hugepage

class { 'cassandra::system::swapoff':
  device => $device,
}

if $sysctl_args {
  class { 'cassandra::system::sysctl':
    sysctl_args => $sysctl_args,
  }
} else {
  require cassandra::system::sysctl
}
