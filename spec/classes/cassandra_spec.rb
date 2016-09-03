require 'spec_helper'
describe 'cassandra' do
  let(:pre_condition) do
    [
      'class apt () {}',
      'class apt::update () {}',
      'define apt::key ($id, $source) {}',
      'define apt::source ($location, $comment, $release, $include) {}',
      'define ini_setting($ensure = nil,
         $path,
         $section,
         $key_val_separator       = nil,
         $setting,
         $value                   = nil) {}'
    ]
  end

  let!(:stdlib_stubs) do
    MockFunction.new('concat') do |f|
      f.stubbed.with([], '')
       .returns([''])
      f.stubbed.with([], '/etc/cassandra')
       .returns(['/etc/cassandra'])
      f.stubbed.with([], '/etc/cassandra/default.conf')
       .returns(['/etc/cassandra/default.conf'])
      f.stubbed.with(['/etc/cassandra'], '/etc/cassandra/default.conf')
       .returns(['/etc/cassandra', '/etc/cassandra/default.conf'])
    end
    MockFunction.new('strftime') do |f|
      f.stubbed.with('/var/lib/cassandra-%F')
       .returns('/var/lib/cassandra-YYYY-MM-DD')
    end
  end

  context 'On an unknown OS with defaults for all parameters' do
    let :facts do
      {
        osfamily: 'Darwin'
      }
    end

    it { should raise_error(Puppet::Error) }
  end

  context 'Test the default parameters' do
    let :facts do
      {
        osfamily: 'RedHat'
      }
    end

    it do
      should contain_file('/etc/cassandra/default.conf/cassandra.yaml')
        .with_content(/^key_cache_size_in_mb:$/)
      should contain_class('cassandra').only_with(
        'additional_lines' => [],
        'authenticator' => 'AllowAllAuthenticator',
        'authorizer' => 'AllowAllAuthorizer',
        'auto_snapshot' => true,
        'batchlog_replay_throttle_in_kb' => 1024,
        'batch_size_warn_threshold_in_kb' => 5,
        'cas_contention_timeout_in_ms' => 1000,
        'cassandra_2356_sleep_seconds' => 5,
        'cassandra_9822' => false,
        'cassandra_yaml_tmpl' => 'cassandra/cassandra.yaml.erb',
        'client_encryption_enabled' => false,
        'client_encryption_keystore' => 'conf/.keystore',
        'client_encryption_keystore_password' => 'cassandra',
        'cluster_name' => 'Test Cluster',
        'column_index_size_in_kb' => 64,
        'commitlog_directory' => '/var/lib/cassandra/commitlog',
        'commitlog_directory_mode' => '0750',
        'commitlog_segment_size_in_mb' => 32,
        'commitlog_sync' => 'periodic',
        'commitlog_sync_period_in_ms' => 10_000,
        'commit_failure_policy' => 'stop',
        # 'compaction_large_partition_warning_threshold_mb' => nil,
        'compaction_throughput_mb_per_sec' => 16,
        'concurrent_counter_writes' => 32,
        'concurrent_reads' => 32,
        'concurrent_writes' => 32,
        'config_file_mode' => '0644',
        'config_path' => '/etc/cassandra/default.conf',
        'config_path_parents' => ['/etc/cassandra'],
        'counter_cache_save_period' => 7200,
        'counter_cache_size_in_mb' => '',
        'counter_write_request_timeout_in_ms' => 5000,
        'cross_node_timeout' => false,
        'data_file_directories' => ['/var/lib/cassandra/data'],
        'data_file_directories_mode' => '0750',
        'dc' => 'DC1',
        'disk_failure_policy' => 'stop',
        'dynamic_snitch_badness_threshold' => 0.1,
        'dynamic_snitch_reset_interval_in_ms' => 600_000,
        'dynamic_snitch_update_interval_in_ms' => 100,
        'endpoint_snitch' => 'SimpleSnitch',
        'fail_on_non_supported_os' => true,
        'hinted_handoff_enabled' => true,
        'hinted_handoff_throttle_in_kb' => 1024,
        'incremental_backups' => false,
        'index_summary_capacity_in_mb' => '',
        'index_summary_resize_interval_in_minutes' => 60,
        'inter_dc_tcp_nodelay' => false,
        'internode_compression' => 'all',
        'key_cache_save_period' => 14_400,
        'key_cache_size_in_mb'  => '',
        'listen_address' => 'localhost',
        'manage_dsc_repo' => false,
        'max_hints_delivery_threads' => 2,
        'max_hint_window_in_ms' => 10_800_000,
        'memtable_allocation_type' => 'heap_buffers',
        'native_transport_port' => 9042,
        'num_tokens' => 256,
        'package_ensure' => 'present',
        'package_name' => 'cassandra22',
        'partitioner' => 'org.apache.cassandra.dht.Murmur3Partitioner',
        'permissions_validity_in_ms' => 2000,
        # 'prefer_local' => nil,
        'rack' => 'RAC1',
        'rackdc_tmpl' => 'cassandra/cassandra-rackdc.properties.erb',
        'range_request_timeout_in_ms' => 10_000,
        'read_request_timeout_in_ms' => 5000,
        'request_scheduler' => 'org.apache.cassandra.scheduler.NoScheduler',
        'request_timeout_in_ms' => 10_000,
        'row_cache_save_period' => 0,
        'row_cache_size_in_mb' => 0,
        'rpc_address' => 'localhost',
        'rpc_port' => 9160,
        'rpc_server_type' => 'sync',
        'saved_caches_directory' => '/var/lib/cassandra/saved_caches',
        'saved_caches_directory_mode' => '0750',
        'seed_provider_class_name' => 'org.apache.cassandra.locator.SimpleSeedProvider',
        'seeds' => '127.0.0.1',
        'server_encryption_internode' => 'none',
        'server_encryption_keystore' => 'conf/.keystore',
        'server_encryption_keystore_password' => 'cassandra',
        'server_encryption_truststore' => 'conf/.truststore',
        'server_encryption_truststore_password' => 'cassandra',
        'service_enable' => true,
        'service_ensure' => 'running',
        'service_name' => 'cassandra',
        'service_provider' => nil,
        'service_refresh' => true,
        'service_systemd' => false,
        'service_systemd_tmpl' => 'cassandra/cassandra.service.erb',
        'snapshot_before_compaction' => false,
        'snitch_properties_file' => 'cassandra-rackdc.properties',
        'ssl_storage_port' => 7001,
        'sstable_preemptive_open_interval_in_mb' => 50,
        'start_native_transport' => true,
        'start_rpc' => true,
        'storage_port' => 7000,
        'thrift_framed_transport_size_in_mb' => 15,
        'tombstone_failure_threshold' => 100_000,
        'tombstone_warn_threshold' => 1000,
        'trickle_fsync' => false,
        'trickle_fsync_interval_in_kb' => 10_240,
        'truncate_request_timeout_in_ms' => 60_000,
        'write_request_timeout_in_ms' => 2000
      )
    end

    it do
      should contain_cassandra__private__data_directory('/var/lib/cassandra/data')
    end
  end

  context 'On an unsupported OS pleading tolerance (with dyslexia)' do
    let :facts do
      {
        osfamily: 'Darwin'
      }
    end
    let :params do
      {
        config_file_mode: '0755',
        config_path: '/etc/cassandra',
        fail_on_non_suppoted_os: false,
        package_name: 'cassandra'
      }
    end

    it { should contain_package('cassandra') }
  end

  context 'On an unsupported OS pleading tolerance' do
    let :facts do
      {
        osfamily: 'Darwin'
      }
    end
    let :params do
      {
        config_file_mode: '0755',
        config_path: '/etc/cassandra',
        fail_on_non_supported_os: false,
        package_name: 'cassandra',
        service_provider: 'base'
      }
    end

    it do
      should contain_file('/etc/cassandra/cassandra.yaml')
        .with('mode' => '0755')
    end

    it do
      should contain_service('cassandra').with(provider: 'base')
    end

    it { should have_resource_count(10) }
  end

  context 'Deprecation warnings.' do
    let :facts do
      {
        osfamily: 'RedHat'
      }
    end
    let :params do
      {
        manage_dsc_repo: true,
        fail_on_non_suppoted_os: false
      }
    end

    it do
      should contain_cassandra__private__deprecation_warning('cassandra::manage_dsc_repo')
      should contain_cassandra__private__deprecation_warning('cassandra::fail_on_non_suppoted_os')
    end
  end

  context 'Ensure cassandra service can be stopped and disabled.' do
    let :facts do
      {
        osfamily: 'Debian'
      }
    end

    let :params do
      {
        service_ensure: 'stopped',
        service_enable: 'false'
      }
    end
    it do
      should contain_service('cassandra')
        .with('ensure' => 'stopped',
              'name'      => 'cassandra',
              'enable'    => 'false')
    end
  end

  context 'Test that interface can be specified instead of an IP address.' do
    let :facts do
      {
        osfamily: 'Debian'
      }
    end

    let :params do
      {
        listen_interface: 'ethX',
        rpc_interface: 'ethY'
      }
    end

    it do
      should contain_file('/etc/cassandra/cassandra.yaml')
        .with_content(/listen_interface: ethX/)
    end
    it do
      should contain_file('/etc/cassandra/cassandra.yaml')
        .with_content(/rpc_interface: ethY/)
    end
  end

  context 'Test that additional lines can be specified.' do
    let :facts do
      {
        osfamily: 'Debian'
      }
    end

    let :params do
      {
        additional_lines: ['# Hello,', '# world!']
      }
    end

    it do
      should contain_file('/etc/cassandra/cassandra.yaml')
        .with_content(/# Hello,/)
    end
    it do
      should contain_file('/etc/cassandra/cassandra.yaml')
        .with_content(/# world!/)
    end
  end
end
