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
  $service_provider    = undef,
  $stomp_interface     = undef,
  $local_interface     = undef,
  $agent_alias         = undef,
  $async_pool_size     = undef,
  $async_queue_size    = undef,
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

  if $agent_alias != undef {
    $ensure_agent_alias = present
  } else {
    $ensure_agent_alias = absent
  }

  ini_setting { 'agent_alias':
    ensure            => $ensure_agent_alias,
    path              => $address_config_file,
    section           => '',
    key_val_separator => ': ',
    setting           => 'alias',
    value             => $agent_alias,
    require           => Package[$package_name],
    notify            => Service[$service_name]
  }

  if $async_pool_size != undef {
    ini_setting { 'async_pool_size':
      ensure            => present,
      path              => $address_config_file,
      section           => '',
      key_val_separator => ': ',
      setting           => 'async_pool_size',
      value             => $async_pool_size,
      require           => Package[$package_name],
      notify            => Service[$service_name]
    }
  }

  if $async_queue_size != undef {
    ini_setting { 'async_queue_size':
      ensure            => present,
      path              => $address_config_file,
      section           => '',
      key_val_separator => ': ',
      setting           => 'async_queue_size',
      value             => $async_queue_size,
      require           => Package[$package_name],
      notify            => Service[$service_name]
    }
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

  if $service_provider != undef {
    System {
      provider => $service_provider
    }
  }

  service { $service_name:
    ensure => $service_ensure,
    enable => $service_enable,
  }
}
