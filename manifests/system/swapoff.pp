# Disable swap on the node as suggested at
# http://docs.datastax.com/en/landing_page/doc/landing_page/recommendedSettingsLinux.html
# @param device [string] If provided a mount resource will be created to
#   ensure that the device is absent from /etc/fstab to permanently disable swap.
# @param grep [string] A path to the grep command.
# @param path [string] The full path to the file to check if swap is enabled.
# @param swapoff [string] The path to the `swapoff` command.
# @see cassandra::params
class cassandra::system::swapoff(
  $device  = undef,
  $grep    = $::cassandra::params::grep,
  $path    = '/proc/swaps',
  $swapoff = $::cassandra::params::swapoff,
  ) inherits cassandra::params {
  exec { 'Disable Swap':
    command => "${swapoff} --all",
    onlyif  => "${grep} -q '^/' ${path}",
  }

  if $device {
    mount { 'swap':
      ensure => absent,
      device => $device,
      fstype => 'swap',
    }
  }
}
