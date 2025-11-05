# @summary Class to manage installation and configuration of Cassandra.
#
# @param config_path
#   Path to cassandra configuration files.
# @param repo_config
#   A hash of repository attributes for configuring the cassandra package repositories.
#   Examples/defaults for yumrepo can be found at data/RedHat.yaml, and for apt at data/Debian.yaml
# @param manage_repo
#   Whether to manage the package repository.
# @param package_ensure
#   Ensure state of the Cassandra package.
# @param package_name
#   The name of the Cassandra package.
# @param tools_ensure
#   Ensure state of the Cassandra tools package.
# @param tools_package
#   The name of the Cassandra tools package.
# @param java_ensure
#   Ensure state of the Java package.
# @param java_package
#   The name of the Java package.
# @param jna_ensure
#   Ensure state of the JNA package.
# @param jna_package
#   The name of the JNA package.
# @param manage_user
#   Whether to manage the Cassandra user and group.
# @param user
#   The name of the Cassandra user.
# @param group
#   The name of the Cassandra group.
# @param system_user
#   Whether to create a system user.
# @param system_group
#   Whether to create a system group.
# @param uid
#   The UID of the Cassandra user.
# @param gid
#   The GID of the Cassandra group.
# @param manage_homedir
#   Whether to manage the home directory of the Cassandra user.
# @param homedir
#   The home directory of the Cassandra user.
# @param shell
#   The login shell of the Cassandra user.
# @param commitlog_directory
#   Path to the commitlog directory.
# @param commitlog_directory_mode
#   Permissions mode for the `commitlog_directory`.
# @param data_file_directories
#   Path(s) to the date directory or directories.
# @param data_file_directories_mode
#   Permissions mode for the `data_file_directories`.
# @param hints_directory
#   Path to the hints directory.
# @param hints_directory_mode
#   Permissions mode for the `hints_directory`.
# @param saved_caches_directory
#   Path to the saved caches directory.
# @param saved_caches_directory_mode
#   Permissions mode for the `saved_caches_directory`.
# @param manage_config_file
#   Whether or not to manage the cassandra configuration  file.
# @param config_file_mode
#   Permissions mode for the cassandra configuration file.
# @param config_template_file
#   The template file to use for the cassandra configuration file.
# @param manage_snitch_file
#   Whether or not to manage the snitch properties file.
# @param snitch_file_mode
#   Permissions mode for the snitch properties file.
# @param snitch_template_file
#   The template file to use for the snitch properties file.
# @param snitch_properties_file
#   The name of the snitch properties file.
# @param baseline_settings
#   This will be merged with the `settings` hash.
#   The values of the `settings` hash will override the values in this hash.
# @param settings
#   A hash that is passed to `to_yaml` which dumps the results to the Cassandra configuring file.
# @param dc
#   Sets the value for dc in `config_path`/`snitch_properties_file`.
# @param dc_suffix
#   Sets the value for dc_suffix in `config_path`/`snitch_properties_file`.
# @param prefer_local
#   Sets the value for prefer_local in `config_path`/`snitch_properties_file`.
# @param rack
#   Sets the value for rack in `config_path`/`snitch_properties_file`.
# @param service_enable
#   Whether to enable the Cassandra service at boot time.
# @param service_ensure
#   Ensure state of the Cassandra service.
# @param service_name
#   The name of the Cassandra service.
# @param service_refresh
#   Whether to refresh the service when configuration changes.
#
class cassandra (
  Stdlib::Absolutepath $config_path,
  Hash $repo_config,
  Boolean $manage_repo = true,
  Stdlib::Ensure::Package $package_ensure = 'installed',
  String[1] $package_name = 'cassandra',
  Stdlib::Ensure::Package $tools_ensure = 'installed',
  String[1] $tools_package = 'cassandra-tools',
  Stdlib::Ensure::Package $java_ensure = 'installed',
  Optional[String[1]] $java_package = undef,
  Stdlib::Ensure::Package $jna_ensure = 'installed',
  Optional[String[1]] $jna_package = undef,
  Boolean $manage_user = false,
  String[1] $user = 'cassandra',
  String[1] $group = 'cassandra',
  Boolean $system_user = true,
  Boolean $system_group = true,
  Optional[Integer] $uid = undef,
  Optional[Integer] $gid = undef,
  Boolean $manage_homedir = true,
  Stdlib::Absolutepath $homedir = '/var/lib/cassandra',
  Stdlib::Absolutepath $shell = '/bin/false',
  Optional[Stdlib::Absolutepath] $commitlog_directory = undef,
  Stdlib::Filemode $commitlog_directory_mode = '0750',
  Optional[Array[Stdlib::Absolutepath]] $data_file_directories = undef,
  Stdlib::Filemode $data_file_directories_mode = '0750',
  Optional[Stdlib::Absolutepath] $hints_directory = undef,
  Stdlib::Filemode $hints_directory_mode = '0750',
  Optional[Stdlib::Absolutepath] $saved_caches_directory = undef,
  Stdlib::Filemode $saved_caches_directory_mode = '0750',
  Boolean $manage_config_file = true,
  Stdlib::Filemode $config_file_mode = '0644',
  String[1] $config_template_file = 'cassandra/cassandra.yaml.epp',
  Boolean $manage_snitch_file = true,
  Stdlib::Filemode $snitch_file_mode = '0644',
  String[1] $snitch_template_file = 'cassandra/cassandra-rackdc.properties.epp',
  Enum[
    'cassandra-rackdc.properties',
    'cassandra-topology.properties'
  ] $snitch_properties_file = 'cassandra-rackdc.properties',
  Hash $baseline_settings = {},
  Hash $settings = {},
  String[1] $dc = 'DC1',
  Optional[String[1]] $dc_suffix = undef,
  Optional[Boolean] $prefer_local = undef,
  String[1] $rack = 'RAC1',
  Boolean $manage_service = true,
  Stdlib::Ensure::Service $service_ensure = 'running',
  Boolean $service_enable = true,
  String[1] $service_name = 'cassandra',
  Boolean $service_refresh = true
) {
  contain cassandra::install
  contain cassandra::config
  contain cassandra::service

  if $service_refresh {
    Class['cassandra::install']
    -> Class['cassandra::config']
    ~> Class['cassandra::service']
  } else {
    Class['cassandra::install']
    -> Class['cassandra::config']
    -> Class['cassandra::service']
  }
}
