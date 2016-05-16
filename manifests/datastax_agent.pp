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
  $service_systemd      = $::cassandra::params::service_systemd,
  $service_systemd_tmpl = 'cassandra/datastax-agent.service.erb',
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
    notify  => Service['datastax-agent'],
  }

  file { $address_config_file:
    owner   => 'cassandra',
    group   => 'cassandra',
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

  if $service_systemd {
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

    file { "${::cassandra::params::systemd_path}/${service_name}.service":
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      content => template($service_systemd_tmpl),
      mode    => '0644',
      before  => Package[$package_name],
      notify  => Exec['datastax_agent_reload_systemctl'],
    }
  }

  service { 'datastax-agent':
    ensure => $service_ensure,
    enable => $service_enable,
    name   => $service_name
  }

  if $settings {
    validate_hash($settings)

    $defaults = {
      path              => $address_config_file,
      key_val_separator => ': ',
      require           => Package[$package_name],
      notify            => Service['datastax-agent'],
    }

    create_ini_settings($settings, $defaults)
  }
}
