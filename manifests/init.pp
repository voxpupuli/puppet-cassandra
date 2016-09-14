# == Class: cassandra
#
# Please see the README for this module for full details of what this class
# does as part of the module and how to use it.
#
class cassandra (
  $cassandra_2356_sleep_seconds                         = 5,
  $cassandra_9822                                       = false,
  $cassandra_yaml_tmpl                                  = 'cassandra/cassandra.yaml.erb',
  $config_file_mode                                     = '0644',
  $config_path                                          = $::cassandra::params::config_path,
  $dc                                                   = 'DC1',
  $dc_suffix                                            = undef,
  $fail_on_non_supported_os                             = true,
  $package_ensure                                       = 'present',
  $package_name                                         = $::cassandra::params::cassandra_pkg,
  $prefer_local                                         = undef,
  $rack                                                 = 'RAC1',
  $rackdc_tmpl                                          = 'cassandra/cassandra-rackdc.properties.erb',
  $service_enable                                       = true,
  $service_ensure                                       = undef,
  $service_name                                         = 'cassandra',
  $service_provider                                     = undef,
  $service_refresh                                      = true,
  $settings                                             = {},
  $snitch_properties_file                               = 'cassandra-rackdc.properties',
  ) inherits cassandra::params {
  if $service_provider != undef {
    Service {
      provider => $service_provider,
    }
  }

  $config_file = "${config_path}/cassandra.yaml"
  $dc_rack_properties_file = "${config_path}/${snitch_properties_file}"

  case $::osfamily {
    'RedHat': {
      $config_file_require = Package['cassandra']
      $config_file_before  = []
      $config_path_require = Package['cassandra']
      $dc_rack_properties_file_require = Package['cassandra']
      $dc_rack_properties_file_before  = []
      $data_dir_require = Package['cassandra']
      $data_dir_before = []

      if $::operatingsystemmajrelease == 7 and $::cassandra::service_provider == 'init' {
        exec { "/sbin/chkconfig --add ${service_name}":
          unless  => "/sbin/chkconfig --list ${service_name}",
          require => Package['cassandra'],
          before  => Service['cassandra'],
        }
      }
    }
    'Debian': {
      $config_file_require = [ User['cassandra'], File[$config_path] ]
      $config_file_before  = Package['cassandra']
      $config_path_require = []
      $dc_rack_properties_file_require = [ User['cassandra'], File[$config_path] ]
      $dc_rack_properties_file_before  = Package['cassandra']
      $data_dir_require = File[$config_file]
      $data_dir_before = Package['cassandra']

      if $cassandra_9822 {
        file { '/etc/init.d/cassandra':
          source => 'puppet:///modules/cassandra/CASSANDRA-9822/cassandra',
          mode   => '0555',
          before => Package['cassandra'],
        }
      }
      # Sleep after package install and before service resource to prevent
      # possible duplicate processes arising from CASSANDRA-2356.
      exec { 'CASSANDRA-2356 sleep':
        command     => "/bin/sleep ${cassandra_2356_sleep_seconds}",
        refreshonly => true,
        user        => 'root',
        subscribe   => Package['cassandra'],
        before      => Service['cassandra'],
      }

      group { 'cassandra':
        ensure  => 'present',
      }

      user { 'cassandra':
        ensure     => 'present',
        comment    => 'Cassandra database,,,',
        gid        => 'cassandra',
        home       => '/var/lib/cassandra',
        shell      => '/bin/false',
        managehome => true,
        require    => Group['cassandra']
      }
      # End of CASSANDRA-2356 specific resources.
    }
    default: {
      if $fail_on_non_supported_os {
        fail("OS family ${::osfamily} not supported")
      } else {
        warning("OS family ${::osfamily} not supported")
      }
    }
  }

  package { 'cassandra':
    ensure => $package_ensure,
    name   => $package_name,
    notify => Exec['cassandra_reload_systemctl'],
  }

  exec { 'cassandra_reload_systemctl':
    command     => "${::cassandra::params::systemctl} daemon-reload",
    onlyif      => "test -x ${::cassandra::params::systemctl}",
    path        => ['/usr/bin', '/bin'],
    refreshonly => true,
  }

  file { $config_path:
    ensure  => 'directory',
    group   => 'cassandra',
    owner   => 'cassandra',
    mode    => '0755',
    require => $config_path_require,
  }

  file { $config_file:
    ensure  => present,
    owner   => 'cassandra',
    group   => 'cassandra',
    content => template($cassandra_yaml_tmpl),
    mode    => $config_file_mode,
    require => $config_file_require,
    before  => $config_file_before,
  }

  file { $dc_rack_properties_file:
    ensure  => 'file',
    content => template($rackdc_tmpl),
    owner   => 'cassandra',
    group   => 'cassandra',
    mode    => '0644',
    require => $dc_rack_properties_file_require,
    before  => $dc_rack_properties_file_before,
  }

  if $package_ensure != 'absent' and $package_ensure != 'purged' {
    if $service_refresh {
      service { 'cassandra':
        ensure    => $service_ensure,
        name      => $service_name,
        enable    => $service_enable,
        subscribe => [
          File[$config_file],
          File[$dc_rack_properties_file],
          Package['cassandra'],
        ],
      }
    } else {
      service { 'cassandra':
        ensure  => $service_ensure,
        name    => $service_name,
        enable  => $service_enable,
        require => [
          File[$config_file],
          File[$dc_rack_properties_file],
          Package['cassandra'],
        ],
      }
    }
  }
}
