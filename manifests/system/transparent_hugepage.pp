# Disable Transparant Huge Pages as suggested in
# http://docs.datastax.com/en/landing_page/doc/landing_page/recommendedSettingsLinux.html.
# @param grep [string] A path to the grep command.
# @param path [string] The full path to the file for checking/setting
#   if Transparent Hugepages is enabled.
# @see cassandra::params
class cassandra::system::transparent_hugepage (
  $grep = $::cassandra::params::grep,
  $path = '/sys/kernel/mm/transparent_hugepage/defrag',
  ) inherits cassandra::params {
  exec { 'Disable Java Hugepages':
    command => "/bin/echo never > ${path}",
    unless  => "${grep} -q '\\[never\\]' ${path}",
  }
}
