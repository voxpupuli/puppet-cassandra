# Install and configure the optional DataStax agent.
class cassandra::datastax_agent (
  $address_config_file  = '/var/lib/datastax-agent/conf/address.yaml',
  $defaults_file        = '/etc/default/datastax-agent',
  $java_home            = undef,
  $package_ensure       = 'present',
  $package_name         = 'datastax-agent',
  $service_ensure       = 'running',
  $service_enable       = true,
  $service_name         = 'datastax-agent',
  $service_provider     = undef,
  $settings             = {}
  ) inherits cassandra::params {
  if $service_provider != undef {
    System {
      provider => $service_provider,
    }
  }

  package { $package_name:
    ensure  => $package_ensure,
    require => Class['cassandra'],
    notify  => Exec['datastax_agent_reload_systemctl'],
  }

  exec { 'datastax_agent_reload_systemctl':
    command     => "${::cassandra::params::systemctl} daemon-reload",
    onlyif      => "test -x ${::cassandra::params::systemctl}",
    path        => ['/usr/bin', '/bin'],
    refreshonly => true,
    notify      => Service['datastax-agent'],
  }

  file { $address_config_file:
    owner   => 'cassandra',
    group   => 'cassandra',
    mode    => '0640',
    require => Package[$package_name],
  }

  if $java_home != undef {
    ini_setting { 'java_home':
      ensure            => present,
      path              => $defaults_file,
      section           => '',
      key_val_separator => '=',
      setting           => 'JAVA_HOME',
      value             => $java_home,
      notify            => Service['datastax-agent'],
    }
  }

  service { 'datastax-agent':
    ensure => $service_ensure,
    enable => $service_enable,
    name   => $service_name
  }

  if $settings {
    $defaults = {
      path              => $address_config_file,
      key_val_separator => ': ',
      require           => Package[$package_name],
      notify            => Service['datastax-agent'],
    }

    $full_settings = {
      '' => $settings
    }

    validate_hash($full_settings)
    create_ini_settings($full_settings, $defaults)
  }
}
