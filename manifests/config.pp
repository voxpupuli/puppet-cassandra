# @api private
#
# @summary This class is called from cassandra to manage the configuration.
#
class cassandra::config {
  file { $cassandra::config_path:
    ensure => directory,
    owner  => $cassandra::user,
    group  => $cassandra::group,
    mode   => '0755',
  }

  if $cassandra::commitlog_directory {
    file { $cassandra::commitlog_directory:
      ensure => directory,
      owner  => $cassandra::user,
      group  => $cassandra::group,
      mode   => $cassandra::commitlog_directory_mode,
    }

    $_commitlog_dir_setting = { 'commitlog_directory' => $cassandra::commitlog_directory }
  } else {
    $_commitlog_dir_setting = {}
  }

  if $cassandra::data_file_directories {
    $cassandra::data_file_directories.each | $_dir | {
      file { $_dir:
        ensure => directory,
        owner  => $cassandra::user,
        group  => $cassandra::group,
        mode   => $cassandra::data_file_directories_mode,
      }
    }

    $_data_file_dirs_setting = { 'data_file_directories' => $cassandra::data_file_directories }
  } else {
    $_data_file_dirs_setting = {}
  }

  if $cassandra::hints_directory {
    file { $cassandra::hints_directory:
      ensure => directory,
      owner  => $cassandra::user,
      group  => $cassandra::group,
      mode   => $cassandra::hints_directory_mode,
    }

    $_hints_dir_setting = { 'hints_directory' => $cassandra::hints_directory }
  } else {
    $_hints_dir_setting = {}
  }

  if $cassandra::saved_caches_directory {
    file { $cassandra::saved_caches_directory:
      ensure => directory,
      owner  => $cassandra::user,
      group  => $cassandra::group,
      mode   => $cassandra::saved_caches_directory_mode,
    }

    $_saved_caches_dir_setting = { 'saved_caches_directory' => $cassandra::saved_caches_directory }
  } else {
    $_saved_caches_dir_setting = {}
  }

  $_merged_settings = stdlib::merge(
    $cassandra::baseline_settings,
    $cassandra::settings,
    $_commitlog_dir_setting,
    $_data_file_dirs_setting,
    $_hints_dir_setting,
    $_saved_caches_dir_setting
  )

  if $cassandra::manage_config_file {
    file { "${cassandra::config_path}/cassandra.yaml":
      ensure  => file,
      owner   => $cassandra::user,
      group   => $cassandra::group,
      mode    => $cassandra::config_file_mode,
      content => epp($cassandra::config_template_file, { settings => $_merged_settings }),
    }
  }

  if $cassandra::manage_snitch_file {
    file { "${cassandra::config_path}/${cassandra::snitch_properties_file}":
      ensure  => file,
      owner   => $cassandra::user,
      group   => $cassandra::group,
      mode    => $cassandra::snitch_file_mode,
      content => epp($cassandra::snitch_template_file,
        {
          dc           => $cassandra::dc,
          dc_suffix    => $cassandra::dc_suffix,
          prefer_local => $cassandra::prefer_local,
          rack         => $cassandra::rack,
        }
      ),
    }
  }
}
