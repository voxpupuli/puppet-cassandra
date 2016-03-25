# Install and configure the optional DataStax agent.
class cassandra::datastax_agent (
  $address_config_file  = '/var/lib/datastax-agent/conf/address.yaml',
  $agent_alias          = undef,
  $async_pool_size      = undef,
  $async_queue_size     = undef,
  $defaults_file        = '/etc/default/datastax-agent',
  $hosts                = undef,
  $java_home            = undef,
  $local_interface      = undef,
  $package_ensure       = 'present',
  $package_name         = 'datastax-agent',
  $service_ensure       = 'running',
  $service_enable       = true,
  $service_name         = 'datastax-agent',
  $service_provider     = undef,
  $service_systemd      = false,
  $service_systemd_tmpl = 'cassandra/datastax-agent.service.erb',
  $stomp_interface      = undef,
  $storage_keyspace     = undef,
  ) inherits cassandra::params {
  if $service_provider != undef {
    System {
      provider => $service_provider,
    }
  }

  package { $package_name:
    ensure  => $package_ensure,
    require => Class['cassandra'],
    notify  => Service[$service_name],
  }

  if $stomp_interface != undef {
    $ensure = present
  } else {
    $ensure = absent
  }

  file { $address_config_file:
    owner   => 'cassandra',
    group   => 'cassandra',
    require => Package[$package_name],
  }

  ini_setting { 'stomp_interface':
    ensure            => $ensure,
    path              => $address_config_file,
    section           => '',
    key_val_separator => ': ',
    setting           => 'stomp_interface',
    value             => $stomp_interface,
    require           => Package[$package_name],
    notify            => Service[$service_name],
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
    notify            => Service[$service_name],
  }

  if $hosts != undef {
    $ensure_hosts = present
  } else {
    $ensure_hosts = absent
  }

  ini_setting { 'hosts':
    ensure            => $ensure_hosts,
    path              => $address_config_file,
    section           => '',
    key_val_separator => ': ',
    setting           => 'hosts',
    value             => $hosts,
    require           => Package[$package_name],
    notify            => Service[$service_name],
  }

  if $storage_keyspace != undef {
    $ensure_storage_keyspace = present
  } else {
    $ensure_storage_keyspace = absent
  }

  ini_setting { 'storage_keyspace':
    ensure            => $ensure_storage_keyspace,
    path              => $address_config_file,
    section           => '',
    key_val_separator => ': ',
    setting           => 'storage_keyspace',
    value             => $storage_keyspace,
    require           => Package[$package_name],
    notify            => Service[$service_name],
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
    notify            => Service[$service_name],
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
      notify            => Service[$service_name],
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
      notify            => Service[$service_name],
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
      notify            => Service[$service_name],
    }
  }

  if $service_systemd {
    if $::osfamily == 'Debian' {
      $systemd_path = '/lib/systemd/system'
    } else {
      $systemd_path = '/usr/lib/systemd/system'
    }

    file { '/var/run/datastax-agent':
      ensure => directory,
      owner  => 'cassandra',
      group  => 'cassandra',
      before => Package[$package_name],
    }

    exec { 'datastax_agent_reload_systemctl':
      command     => "${::cassandra::params::systemctl} daemon-reload",
      refreshonly => true,
    }

    file { "${systemd_path}/${service_name}.service":
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      content => template($service_systemd_tmpl),
      mode    => '0644',
      before  => Package[$package_name],
      notify  => Exec['datastax_agent_reload_systemctl'],
    }
  }

  service { $service_name:
    ensure => $service_ensure,
    enable => $service_enable,
  }
}
