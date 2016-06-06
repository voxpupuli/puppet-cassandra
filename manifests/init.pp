# == Class: cassandra
#
# Please see the README for this module for full details of what this class
# does as part of the module and how to use it.
#
class cassandra (
  $cassandra_2356_sleep_seconds                         = 5,
  $cassandra_9822                                       = false,
  $cassandra_yaml_tmpl
    = 'cassandra/cassandra.yaml.erb',
  $commitlog_directory
    = '/var/lib/cassandra/commitlog',
  $config_file_mode                                     = '0644',
  $config_path                                          = $::cassandra::params::config_path,
  $config_path_parents                                  = $::cassandra::params::config_path_parents,
  $data_file_directories
    = ['/var/lib/cassandra/data'],
  $data_file_directories_mode                           = '0750',
  $dc                                                   = 'DC1',
  $dc_suffix                                            = undef,
  $fail_on_non_supported_os                             = true,
  $package_ensure                                       = 'present',
  $package_name                                         = $::cassandra::params::cassandra_pkg,
  $prefer_local                                         = undef,
  $rack                                                 = 'RAC1',
  $rackdc_tmpl
    = 'cassandra/cassandra-rackdc.properties.erb',
  $saved_caches_directory
    = '/var/lib/cassandra/saved_caches',
  $saved_caches_directory_mode                          = '0750',
  $service_enable                                       = true,
  $service_ensure                                       = 'running',
  $service_name                                         = 'cassandra',
  $service_provider                                     = undef,
  $service_refresh                                      = true,
  $service_systemd                                      = $::cassandra::params::service_systemd,
  $service_systemd_tmpl                                 = 'cassandra/cassandra.service.erb',
  $settings                                             = {},
  $snitch_properties_file
    = 'cassandra-rackdc.properties',
  ) inherits cassandra::params {
  if $service_provider != undef {
    Service {
      provider => $service_provider,
    }
  }

  $config_file = "${config_path}/cassandra.yaml"
  $config_path_recurse = concat ($config_path_parents, $config_path)
  $dc_rack_properties_file = "${config_path}/${snitch_properties_file}"

  case $::osfamily {
    'RedHat': {
      $config_file_require = Package['cassandra']
      $config_file_before  = []
      $config_path_recurse_require = Package['cassandra']
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
      $config_file_require = [ User['cassandra'], File[$config_path_recurse] ]
      $config_file_before  = Package['cassandra']
      $config_path_recurse_require = []
      $dc_rack_properties_file_require = [ User['cassandra'], File[$config_path_recurse] ]
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
  }

  if $service_systemd {
    exec { 'cassandra_reload_systemctl':
      command     => "${::cassandra::params::systemctl} daemon-reload",
      refreshonly => true,
    }

    file { "${::cassandra::params::systemd_path}/${service_name}.service":
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      content => template($service_systemd_tmpl),
      mode    => '0644',
      before  => Package['cassandra'],
      notify  => Exec[cassandra_reload_systemctl],
    }
  }

  file { $config_path_recurse:
    ensure  => 'directory',
    group   => 'cassandra',
    owner   => 'cassandra',
    mode    => '0755',
    require => $config_path_recurse_require,
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

  if ! defined( File[$commitlog_directory] ) {
    file { $commitlog_directory:
      ensure  => directory,
      owner   => 'cassandra',
      group   => 'cassandra',
      mode    => $commitlog_directory_mode,
      require => $data_dir_require,
      before  => $data_dir_before,
    }
  }

  cassandra::private::data_directory { $data_file_directories: }

  if ! defined( File[$saved_caches_directory] ) {
    file { $saved_caches_directory:
      ensure  => directory,
      owner   => 'cassandra',
      group   => 'cassandra',
      mode    => $saved_caches_directory_mode,
      require => $data_dir_require,
      before  => $data_dir_before,
    }
  }

  if $package_ensure != 'absent' and $package_ensure != 'purged' {
    if $service_refresh {
      service { 'cassandra':
        ensure    => $service_ensure,
        name      => $service_name,
        enable    => $service_enable,
        subscribe => [
          File[$commitlog_directory],
          File[$config_file],
          File[$data_file_directories],
          File[$saved_caches_directory],
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
          File[$commitlog_directory],
          File[$config_file],
          File[$data_file_directories],
          File[$saved_caches_directory],
          File[$dc_rack_properties_file],
          Package['cassandra'],
        ],
      }
    }
  }
}
