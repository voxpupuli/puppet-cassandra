# Install and configure the optional DataStax agent.
class cassandra::datastax_agent (
  $defaults_file       = '/etc/default/datastax-agent',
  $address_config_file = '/var/lib/datastax-agent/conf/address.yaml',
  $java_home           = undef,
  $package_ensure      = 'present',
  $package_name        = 'datastax-agent',
  $service_ensure      = 'running',
  $service_enable      = true,
  $service_name        = 'datastax-agent',
  $stomp_interface     = undef,
  $local_interface     = undef,
  ){
  package { $package_name:
    ensure  => $package_ensure,
    require => Class['cassandra'],
    notify  => Service[$service_name]
  }

  if $stomp_interface != undef {
    $ensure = present
  } else {
    $ensure = absent
  }

  ini_setting { 'stomp_interface':
    ensure            => $ensure,
    path              => $address_config_file,
    section           => '',
    key_val_separator => ': ',
    setting           => 'stomp_interface',
    value             => $stomp_interface,
    require           => Package[$package_name],
    notify            => Service[$service_name]
  }

  if $local_interface != undef {
    $ensure_local_interface = present
  } else {
    $ensure_local_interface = absent
  }

  ini_setting { 'local_interface':
    ensure            => $ensure_local_interface,
    path              => $address_config_file,
    section           => '',
    key_val_separator => ': ',
    setting           => 'local_interface',
    value             => $local_interface,
    require           => Package[$package_name],
    notify            => Service[$service_name]
  }

  if $java_home != undef {
    ini_setting { 'java_home':
      ensure            => present,
      path              => $defaults_file,
      section           => '',
      key_val_separator => '=',
      setting           => 'JAVA_HOME',
      value             => $java_home,
      notify            => Service[$service_name]
    }
  }

  service { $service_name:
    ensure => $service_ensure,
    enable => $service_enable,
  }
}
