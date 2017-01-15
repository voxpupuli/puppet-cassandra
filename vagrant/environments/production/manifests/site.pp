# Cassandra pre-requisites
require cassandra::system::transparent_hugepage

case "${::operatingsystem}-${operatingsystemmajrelease}" {
  'CentOS-6': {
    $device = '/dev/mapper/VolGroup-lv_swap'
    $sysctl_args = '-e -p'
  }
  'CentOS-7': {
    $device = '/dev/mapper/centos-swap'
  }
  'Debian-8': {
    $device = '/dev/mapper/localhost--vg-swap_1'
    $mount = 'none'
  }
  default: {}
}

if $mount {
  class { 'cassandra::system::swapoff':
    device => $device,
    mount  => $mount
  }
} else {
  class { 'cassandra::system::swapoff':
    device => $device
  }
}

if $sysctl_args {
  class { 'cassandra::system::sysctl':
    sysctl_args => $sysctl_args,
  }
} else {
  require cassandra::system::sysctl
}
