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

  context 'Test the cassandra.yml temlate.' do
    let :facts do
      {
        osfamily: 'RedHat'
      }
    end

    let :params do
      {
        authenticator: 'foo',
        authorizer: 'foo',
        auto_bootstrap: false,
        auto_snapshot: 'foo',
        batch_size_warn_threshold_in_kb: '42',
        client_encryption_enabled: 'foo',
        client_encryption_keystore: 'foo',
        client_encryption_keystore_password: 'foo',
        cluster_name: 'foo',
        concurrent_counter_writes: 'foo',
        concurrent_reads: 'foo',
        concurrent_writes: 'foo',
        config_path: '/etc',
        disk_failure_policy: 'foo',
        endpoint_snitch: 'foo',
        hinted_handoff_enabled: 'foo',
        hints_directory: 'hints_dir',
        incremental_backups: 'foo',
        internode_compression: 'foo',
        listen_address: 'foo',
        native_transport_port: 'foo',
        num_tokens: 'foo',
        partitioner: 'foo',
        rpc_address: 'foo',
        rpc_port: 'foo',
        rpc_server_type: 'foo',
        seeds: 'foo',
        server_encryption_internode: 'foo',
        server_encryption_keystore: 'foo',
        server_encryption_keystore_password: 'foo',
        server_encryption_truststore: 'foo',
        server_encryption_truststore_password: 'foo',
        snapshot_before_compaction: 'foo',
        ssl_storage_port: 'foo',
        start_native_transport: 'foo',
        start_rpc: 'foo',
        storage_port: 'foo',
        batchlog_replay_throttle_in_kb: 'batchlog_replay_throttle_in_kb',
        cas_contention_timeout_in_ms: 'cas_contention_timeout_in_ms',
        column_index_size_in_kb: 'column_index_size_in_kb',
        commit_failure_policy: 'commit_failure_policy',
        compaction_throughput_mb_per_sec: 'compaction_throughput_mb_per_sec',
        counter_cache_save_period: 'counter_cache_save_period',
        counter_write_request_timeout_in_ms:
          'counter_write_request_timeout_in_ms',
        cross_node_timeout: 'cross_node_timeout',
        dynamic_snitch_badness_threshold: 'dynamic_snitch_badness_threshold',
        dynamic_snitch_reset_interval_in_ms:
          'dynamic_snitch_reset_interval_in_ms',
        dynamic_snitch_update_interval_in_ms:
          'dynamic_snitch_update_interval_in_ms',
        hinted_handoff_throttle_in_kb: 'hinted_handoff_throttle_in_kb',
        index_summary_resize_interval_in_minutes:
          'index_summary_resize_interval_in_minutes',
        inter_dc_tcp_nodelay: 'inter_dc_tcp_nodelay',
        max_hints_delivery_threads: 'max_hints_delivery_threads',
        max_hint_window_in_ms: 'max_hint_window_in_ms',
        memtable_allocation_type: 'offheap_buffers',
        permissions_validity_in_ms: 'permissions_validity_in_ms',
        range_request_timeout_in_ms: 'range_request_timeout_in_ms',
        read_request_timeout_in_ms: 'read_request_timeout_in_ms',
        request_scheduler: 'request_scheduler',
        request_timeout_in_ms: 'request_timeout_in_ms',
        row_cache_save_period: 'row_cache_save_period',
        row_cache_size_in_mb: 'row_cache_size_in_mb',
        sstable_preemptive_open_interval_in_mb:
          'sstable_preemptive_open_interval_in_mb',
        tombstone_failure_threshold: 'tombstone_failure_threshold',
        tombstone_warn_threshold: 'tombstone_warn_threshold',
        trickle_fsync: 'trickle_fsync',
        trickle_fsync_interval_in_kb: 'trickle_fsync_interval_in_kb',
        truncate_request_timeout_in_ms: 'truncate_request_timeout_in_ms',
        write_request_timeout_in_ms: 'write_request_timeout_in_ms',
        commitlog_directory: 'commitlog_directory',
        saved_caches_directory: 'saved_caches_directory',
        data_file_directories: %w(datadir1 datadir2),
        initial_token: 'initial_token',
        permissions_update_interval_in_ms: 'permissions_update_interval_in_ms',
        row_cache_keys_to_save: 'row_cache_keys_to_save',
        counter_cache_keys_to_save: 'counter_cache_keys_to_save',
        memory_allocator: 'memory_allocator',
        commitlog_sync: 'commitlog_sync',
        commitlog_sync_batch_window_in_ms: 'commitlog_sync_batch_window_in_ms',
        file_cache_size_in_mb: 'file_cache_size_in_mb',
        memtable_heap_space_in_mb: 'memtable_heap_space_in_mb',
        memtable_offheap_space_in_mb: 'memtable_offheap_space_in_mb',
        memtable_cleanup_threshold: 'memtable_cleanup_threshold',
        commitlog_total_space_in_mb: 'commitlog_total_space_in_mb',
        memtable_flush_writers: 'memtable_flush_writers',
        broadcast_address: 'broadcast_address',
        internode_authenticator: 'internode_authenticator',
        native_transport_max_threads: 'native_transport_max_threads',
        native_transport_max_frame_size_in_mb:
          'native_transport_max_frame_size_in_mb',
        native_transport_max_concurrent_connections:
          'native_transport_max_concurrent_connections',
        native_transport_max_concurrent_connections_per_ip:
          'native_transport_max_concurrent_connections_per_ip',
        broadcast_rpc_address: 'broadcast_rpc_address',
        rpc_min_threads: 'rpc_min_threads',
        rpc_max_threads: 'rpc_max_threads',
        rpc_send_buff_size_in_bytes: 'rpc_send_buff_size_in_bytes',
        rpc_recv_buff_size_in_bytes: 'rpc_recv_buff_size_in_bytes',
        internode_send_buff_size_in_bytes: 'internode_send_buff_size_in_bytes',
        internode_recv_buff_size_in_bytes: 'internode_recv_buff_size_in_bytes',
        concurrent_compactors: 'concurrent_compactors',
        stream_throughput_outbound_megabits_per_sec:
          'stream_throughput_outbound_megabits_per_sec',
        inter_dc_stream_throughput_outbound_megabits_per_sec:
          'inter_dc_stream_throughput_outbound_megabits_per_sec',
        streaming_socket_timeout_in_ms: 'streaming_socket_timeout_in_ms',
        phi_convict_threshold: 'phi_convict_threshold',
        request_scheduler_options_throttle_limit:
          'request_scheduler_options_throttle_limit',
        request_scheduler_options_default_weight:
          'request_scheduler_options_default_weight',
        commitlog_sync_period_in_ms: 'commitlog_sync_period_in_ms',
        commitlog_segment_size_in_mb: 'commitlog_segment_size_in_mb',
        key_cache_size_in_mb: 'key_cache_size_in_mb',
        key_cache_save_period: 'key_cache_save_period',
        client_encryption_algorithm: 'client_encryption_algorithm',
        client_encryption_cipher_suites: 'client_encryption_cipher_suites',
        client_encryption_protocol: 'client_encryption_protocol',
        client_encryption_require_client_auth:
          'client_encryption_require_client_auth',
        client_encryption_store_type: 'client_encryption_store_type',
        client_encryption_truststore_password: 'l138',
        client_encryption_truststore: 'client_encryption_truststore',
        counter_cache_size_in_mb: 'counter_cache_size_in_mb',
        index_summary_capacity_in_mb: 'l141',
        key_cache_keys_to_save: 'key_cache_keys_to_save',
        seed_provider_class_name: 'seed_provider_class_name',
        server_encryption_algorithm: 'server_encryption_algorithm',
        server_encryption_cipher_suites: 'server_encryption_cipher_suites',
        server_encryption_protocol: 'l146',
        server_encryption_require_client_auth: 'l147',
        server_encryption_store_type: 'l148',
        thrift_framed_transport_size_in_mb: 16,
        compaction_large_partition_warning_threshold_mb: 128
      }
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/authenticator: foo/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/authorizer: foo/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/auto_bootstrap: false/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/auto_snapshot: foo/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/enabled: foo/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/keystore: foo/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/keystore_password: foo/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/batch_size_warn_threshold_in_kb: 42/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/cluster_name: 'foo'/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/concurrent_counter_writes: foo/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/concurrent_reads: foo/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/concurrent_writes: foo/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/disk_failure_policy: foo/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/endpoint_snitch: foo/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/hinted_handoff_enabled: foo/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/hints_directory: hints_dir/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/incremental_backups: foo/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/internode_compression: foo/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/listen_address: foo/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/native_transport_port: foo/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/num_tokens: foo/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/partitioner: foo/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/rpc_address: foo/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/rpc_port: foo/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/rpc_server_type: foo/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/ - seeds: "foo"/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/internode_encryption: foo/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/keystore: foo/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/keystore_password: foo/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/truststore: foo/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/truststore_password: foo/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/snapshot_before_compaction: foo/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/ssl_storage_port: foo/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/start_native_transport: foo/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/start_rpc: foo/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/storage_port: foo/)
    end

    key = 'batchlog_replay_throttle_in_kb'
    val = 'batchlog_replay_throttle_in_kb'
    content = key << ': ' << val

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(Regexp.new(content))
    end

    key = 'cas_contention_timeout_in_ms'
    val = 'cas_contention_timeout_in_ms'
    content = key << ': ' << val

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(Regexp.new(content))
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/column_index_size_in_kb: column_index_size_in_kb/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/commit_failure_policy: commit_failure_policy/)
    end

    key = 'compaction_throughput_mb_per_sec'
    val = 'compaction_throughput_mb_per_sec'
    content = key << ': ' << val

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(Regexp.new(content))
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/counter_cache_save_period: counter_cache_save_period/)
    end

    key = 'counter_write_request_timeout_in_ms'
    val = 'counter_write_request_timeout_in_ms'
    content = key << ': ' << val

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(Regexp.new(content))
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/cross_node_timeout: cross_node_timeout/)
    end

    key = 'dynamic_snitch_badness_threshold'
    val = 'dynamic_snitch_badness_threshold'
    content = key << ': ' << val

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(Regexp.new(content))
    end

    key = 'dynamic_snitch_reset_interval_in_ms'
    val = 'dynamic_snitch_reset_interval_in_ms'
    content = key << ': ' << val

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(Regexp.new(content))
    end

    key = 'dynamic_snitch_update_interval_in_ms'
    val = 'dynamic_snitch_update_interval_in_ms'
    content = key << ': ' << val

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(Regexp.new(content))
    end

    key = 'hinted_handoff_throttle_in_kb'
    val = 'hinted_handoff_throttle_in_kb'
    content = key << ': ' << val

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(Regexp.new(content))
    end

    key = 'index_summary_resize_interval_in_minutes'
    val = 'index_summary_resize_interval_in_minutes'
    content = key << ': ' << val

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(Regexp.new(content))
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/inter_dc_tcp_nodelay: inter_dc_tcp_nodelay/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/max_hints_delivery_threads: max_hints_delivery_threads/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/max_hint_window_in_ms: max_hint_window_in_ms/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/memtable_allocation_type: offheap_buffers/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/permissions_validity_in_ms: permissions_validity_in_ms/)
    end

    key = 'range_request_timeout_in_ms'
    val = 'range_request_timeout_in_ms'
    content = key << ': ' << val

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(Regexp.new(content))
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/read_request_timeout_in_ms: read_request_timeout_in_ms/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/request_scheduler: request_scheduler/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/request_timeout_in_ms: request_timeout_in_ms/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/row_cache_save_period: row_cache_save_period/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/row_cache_size_in_mb: row_cache_size_in_mb/)
    end

    key = 'range_request_timeout_in_ms'
    val = 'range_request_timeout_in_ms'
    content = key << ': ' << val

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(Regexp.new(content))
    end

    key = 'tombstone_failure_threshold'
    val = 'tombstone_failure_threshold'
    content = key << ': ' << val

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(Regexp.new(content))
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/tombstone_warn_threshold: tombstone_warn_threshold/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/trickle_fsync: trickle_fsync/)
    end

    key = 'truncate_request_timeout_in_ms'
    val = 'truncate_request_timeout_in_ms'
    content = key << ': ' << val

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(Regexp.new(content))
    end

    key = 'truncate_request_timeout_in_ms'
    val = 'truncate_request_timeout_in_ms'
    content = key << ': ' << val

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(Regexp.new(content))
    end

    key = 'write_request_timeout_in_ms'
    val = 'write_request_timeout_in_ms'
    content = key << ': ' << val

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(Regexp.new(content))
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/commitlog_directory: commitlog_directory/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/saved_caches_directory: saved_caches_directory/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/    - datadir1/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/    - datadir2/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/initial_token: initial_token/)
    end

    key = 'permissions_update_interval_in_ms'
    val = 'permissions_update_interval_in_ms'
    content = key << ': ' << val

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(Regexp.new(content))
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/row_cache_keys_to_save: row_cache_keys_to_save/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/counter_cache_keys_to_save: counter_cache_keys_to_save/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/memory_allocator: memory_allocator/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/commitlog_sync: commitlog_sync/)
    end

    key = 'commitlog_sync_batch_window_in_ms'
    val = 'commitlog_sync_batch_window_in_ms'
    content = key << ': ' << val

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(Regexp.new(content))
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/file_cache_size_in_mb: file_cache_size_in_mb/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/memtable_heap_space_in_mb: memtable_heap_space_in_mb/)
    end

    key = 'memtable_offheap_space_in_mb'
    val = 'memtable_offheap_space_in_mb'
    content = key << ': ' << val

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(Regexp.new(content))
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/memtable_cleanup_threshold: memtable_cleanup_threshold/)
    end

    key = 'commitlog_total_space_in_mb'
    val = 'commitlog_total_space_in_mb'
    content = key << ': ' << val

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(Regexp.new(content))
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/memtable_flush_writers: memtable_flush_writers/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/broadcast_address: broadcast_address/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/internode_authenticator: internode_authenticator/)
    end

    key = 'native_transport_max_threads'
    val = 'native_transport_max_threads'
    content = key << ': ' << val

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(Regexp.new(content))
    end

    key = 'native_transport_max_frame_size_in_mb'
    val = 'native_transport_max_frame_size_in_mb'
    content = key << ': ' << val

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(Regexp.new(content))
    end

    key = 'native_transport_max_concurrent_connections'
    val = 'native_transport_max_concurrent_connections'
    content = key << ': ' << val

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(Regexp.new(content))
    end

    key = 'native_transport_max_concurrent_connections_per_ip'
    val = 'native_transport_max_concurrent_connections_per_ip'
    content = key << ': ' << val

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(Regexp.new(content))
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/broadcast_rpc_address: broadcast_rpc_address/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/rpc_min_threads: rpc_min_threads/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/rpc_max_threads: rpc_max_threads/)
    end

    key = 'rpc_send_buff_size_in_bytes'
    val = 'rpc_send_buff_size_in_bytes'
    content = key << ': ' << val

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(Regexp.new(content))
    end

    key = 'rpc_recv_buff_size_in_bytes'
    val = 'rpc_recv_buff_size_in_bytes'
    content = key << ': ' << val

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(Regexp.new(content))
    end

    key = 'internode_send_buff_size_in_bytes'
    val = 'internode_send_buff_size_in_bytes'
    content = key << ': ' << val

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(Regexp.new(content))
    end

    key = 'internode_recv_buff_size_in_bytes'
    val = 'internode_recv_buff_size_in_bytes'
    content = key << ': ' << val

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(Regexp.new(content))
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/concurrent_compactors: concurrent_compactors/)
    end

    key = 'stream_throughput_outbound_megabits_per_sec'
    val = 'stream_throughput_outbound_megabits_per_sec'
    content = key << ': ' << val

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(Regexp.new(content))
    end

    key = 'inter_dc_stream_throughput_outbound_megabits_per_sec'
    val = 'inter_dc_stream_throughput_outbound_megabits_per_sec'
    content = key << ': ' << val

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(Regexp.new(content))
    end

    key = 'streaming_socket_timeout_in_ms'
    val = 'streaming_socket_timeout_in_ms'
    content = key << ': ' << val

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(Regexp.new(content))
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/phi_convict_threshold: phi_convict_threshold/)
    end

    key = 'request_scheduler_options_throttle_limit'
    val = 'request_scheduler_options_throttle_limit'
    content = key << ': ' << val

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(Regexp.new(content))
    end

    key = 'request_scheduler_options_default_weight'
    val = 'request_scheduler_options_default_weight'
    content = key << ': ' << val

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(Regexp.new(content))
    end

    key = 'commitlog_sync_period_in_ms'
    val = 'commitlog_sync_period_in_ms'
    content = key << ': ' << val

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(Regexp.new(content))
    end

    key = 'commitlog_segment_size_in_mb'
    val = 'commitlog_segment_size_in_mb'
    content = key << ': ' << val

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(Regexp.new(content))
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/key_cache_size_in_mb: key_cache_size_in_mb/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/key_cache_save_period: key_cache_save_period/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/algorithm: client_encryption_algorithm/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/cipher_suites: client_encryption_cipher_suites/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/protocol: client_encryption_protocol/)
    end

    key = 'require_client_auth'
    val = 'client_encryption_require_client_auth'
    content = key << ': ' << val

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(Regexp.new(content))
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/store_type: client_encryption_store_type/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/truststore: client_encryption_truststore/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/truststore_password: l138/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/counter_cache_size_in_mb: counter_cache_size_in_mb/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/index_summary_capacity_in_mb: l141/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/key_cache_keys_to_save: key_cache_keys_to_save/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/- class_name: seed_provider_class_name/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/algorithm: server_encryption_algorithm/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/cipher_suites: server_encryption_cipher_suites/)
    end

    it do
      should contain_file('/etc/cassandra.yaml').with_content(/protocol: l146/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/require_client_auth: l147/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/store_type: l148/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/thrift_framed_transport_size_in_mb: 16/)
    end

    it do
      should contain_file('/etc/cassandra.yaml')
        .with_content(/compaction_large_partition_warning_threshold_mb: 128/)
    end

    it { should contain_file('commitlog_directory') }
    it { should contain_file('datadir1') }
    it { should contain_file('datadir2') }
    it { should contain_cassandra__private__data_directory('datadir1') }
    it { should contain_cassandra__private__data_directory('datadir2') }
    it { should contain_file('saved_caches_directory') }
  end
end
