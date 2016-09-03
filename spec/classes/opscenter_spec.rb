require 'spec_helper'
describe 'cassandra::opscenter' do
  let(:pre_condition) do
    [
      'define ini_setting ($ensure = nil,
        $path,
        $section,
        $key_val_separator = nil,
        $setting,
        $value = nil) {}'
    ]
  end

  context 'Systemd (Red Hat).' do
    let :facts do
      {
        osfamily: 'RedHat'
      }
    end

    let :params do
      {
        service_systemd: true
      }
    end

    it do
      should contain_cassandra__private__deprecation_warning('opscenter::service_systemd')
      should contain_exec('opscenter_reload_systemctl')
      should have_resource_count(258)
    end
  end

  context 'Systemd (Debian).' do
    let :facts do
      {
        osfamily: 'Debian'
      }
    end

    let :params do
      {
        service_systemd: true
      }
    end

    it do
      should contain_cassandra__private__deprecation_warning('opscenter::service_systemd')
      should have_resource_count(258)
    end
  end

  context 'With package_ensure set' do
    let :params do
      {
        package_ensure: '2.1.13-1'
      }
    end

    it { should contain_package('opscenter').with_ensure('2.1.13-1') }
  end

  context 'With both ensure and package_ensure set differently.' do
    let :params do
      {
        package_ensure: '2.1.13-1',
        ensure: 'latest'
      }
    end

    it { should raise_error(Puppet::Error) }
  end

  context 'With both ensure and package_ensure set the same' do
    let :params do
      {
        ensure: '2.1.13-1',
        package_ensure: '2.1.13-1'
      }
    end

    it { should contain_package('opscenter').with_ensure('2.1.13-1') }
  end

  context 'With ensure set.' do
    let :params do
      {
        ensure: '2.1.13-1'
      }
    end

    it do
      should contain_package('opscenter').with_ensure('2.1.13-1')
      should contain_cassandra__private__deprecation_warning('cassandra::opscenter::ensure')
    end
  end

  context 'Test params for cassandra::opscenter defaults.' do
    it do
      should contain_class('cassandra::opscenter')
        .with('authentication_enabled' => 'False',
              'ensure'                 => 'present',
              'config_file'            => '/etc/opscenter/opscenterd.conf',
              'package_name'           => 'opscenter',
              'service_enable'         => 'true',
              'service_ensure'         => 'running',
              'service_name'           => 'opscenterd',
              'service_systemd'        => false,
              'service_systemd_tmpl'   => 'cassandra/opscenterd.service.erb',
              'webserver_interface'    => '0.0.0.0',
              'webserver_port'         => 8888)
    end

    it do
      should have_resource_count(257)
      should contain_cassandra__private__opscenter__setting('agents agent_certfile')
      should contain_cassandra__private__opscenter__setting('agents agent_keyfile')
      should contain_cassandra__private__opscenter__setting('agents agent_keyfile_raw')
      should contain_cassandra__private__opscenter__setting('agents config_sleep')
      should contain_cassandra__private__opscenter__setting('agents fingerprint_throttle')
      should contain_cassandra__private__opscenter__setting('agents incoming_interface')
      should contain_cassandra__private__opscenter__setting('agents incoming_port')
      should contain_cassandra__private__opscenter__setting('agents install_throttle')
      should contain_cassandra__private__opscenter__setting('agents not_seen_threshold')
      should contain_cassandra__private__opscenter__setting('agents path_to_deb')
      should contain_cassandra__private__opscenter__setting('agents path_to_find_java')
      should contain_cassandra__private__opscenter__setting('agents path_to_installscript')
      should contain_cassandra__private__opscenter__setting('agents path_to_rpm')
      should contain_cassandra__private__opscenter__setting('agents path_to_sudowrap')
      should contain_cassandra__private__opscenter__setting('agents reported_interface')
      should contain_cassandra__private__opscenter__setting('agents runs_sudo')
      should contain_cassandra__private__opscenter__setting('agents scp_executable')
      should contain_cassandra__private__opscenter__setting('agents ssh_executable')
      should contain_cassandra__private__opscenter__setting('agents ssh_keygen_executable')
      should contain_cassandra__private__opscenter__setting('agents ssh_keyscan_executable')
      should contain_cassandra__private__opscenter__setting('agents ssh_port')
      should contain_cassandra__private__opscenter__setting('agents ssh_sys_known_hosts_file')
      should contain_cassandra__private__opscenter__setting('agents ssh_user_known_hosts_file')
      should contain_cassandra__private__opscenter__setting('agents ssl_certfile')
      should contain_cassandra__private__opscenter__setting('agents ssl_keyfile')
      should contain_cassandra__private__opscenter__setting('agents tmp_dir')
      should contain_cassandra__private__opscenter__setting('agents use_ssl')
      should contain_cassandra__private__opscenter__setting('authentication audit_auth')
      should contain_cassandra__private__opscenter__setting('authentication audit_pattern')
      should contain_cassandra__private__opscenter__setting('authentication authentication_method')
      should contain_cassandra__private__opscenter__setting('authentication enabled')
      should contain_cassandra__private__opscenter__setting('authentication passwd_db')
      should contain_cassandra__private__opscenter__setting('authentication timeout')
      should contain_cassandra__private__opscenter__setting('cloud accepted_certs')
      should contain_cassandra__private__opscenter__setting('clusters add_cluster_timeout')
      should contain_cassandra__private__opscenter__setting('clusters startup_sleep')
      should contain_cassandra__private__opscenter__setting('definitions auto_update')
      should contain_cassandra__private__opscenter__setting('definitions definitions_dir')
      should contain_cassandra__private__opscenter__setting('definitions download_filename')
      should contain_cassandra__private__opscenter__setting('definitions download_host')
      should contain_cassandra__private__opscenter__setting('definitions download_port')
      should contain_cassandra__private__opscenter__setting('definitions hash_filename')
      should contain_cassandra__private__opscenter__setting('definitions sleep')
      should contain_cassandra__private__opscenter__setting('definitions ssl_certfile')
      should contain_cassandra__private__opscenter__setting('definitions use_ssl')
      should contain_cassandra__private__opscenter__setting('failover failover_configuration_directory')
      should contain_cassandra__private__opscenter__setting('failover heartbeat_fail_window')
      should contain_cassandra__private__opscenter__setting('failover heartbeat_period')
      should contain_cassandra__private__opscenter__setting('failover heartbeat_reply_period')
      should contain_cassandra__private__opscenter__setting('hadoop base_job_tracker_proxy_port')
      should contain_cassandra__private__opscenter__setting('labs orbited_longpoll')
      should contain_cassandra__private__opscenter__setting('ldap admin_group_name')
      should contain_cassandra__private__opscenter__setting('ldap connection_timeout')
      should contain_cassandra__private__opscenter__setting('ldap debug_ssl')
      should contain_cassandra__private__opscenter__setting('ldap group_name_attribute')
      should contain_cassandra__private__opscenter__setting('ldap group_search_base')
      should contain_cassandra__private__opscenter__setting('ldap group_search_filter')
      should contain_cassandra__private__opscenter__setting('ldap group_search_filter_with_dn')
      should contain_cassandra__private__opscenter__setting('ldap group_search_type')
      should contain_cassandra__private__opscenter__setting('ldap ldap_security')
      should contain_cassandra__private__opscenter__setting('ldap opt_referrals')
      should contain_cassandra__private__opscenter__setting('ldap protocol_version')
      should contain_cassandra__private__opscenter__setting('ldap search_dn')
      should contain_cassandra__private__opscenter__setting('ldap search_password')
      should contain_cassandra__private__opscenter__setting('ldap server_host')
      should contain_cassandra__private__opscenter__setting('ldap server_port')
      should contain_cassandra__private__opscenter__setting('ldap ssl_cacert')
      should contain_cassandra__private__opscenter__setting('ldap ssl_cert')
      should contain_cassandra__private__opscenter__setting('ldap ssl_key')
      should contain_cassandra__private__opscenter__setting('ldap tls_demand')
      should contain_cassandra__private__opscenter__setting('ldap tls_reqcert')
      should contain_cassandra__private__opscenter__setting('ldap uri_scheme')
      should contain_cassandra__private__opscenter__setting('ldap user_memberof_attribute')
      should contain_cassandra__private__opscenter__setting('ldap user_search_base')
      should contain_cassandra__private__opscenter__setting('ldap user_search_filter')
      should contain_cassandra__private__opscenter__setting('logging level')
      should contain_cassandra__private__opscenter__setting('logging log_length')
      should contain_cassandra__private__opscenter__setting('logging log_path')
      should contain_cassandra__private__opscenter__setting('logging max_rotate')
      should contain_cassandra__private__opscenter__setting('logging resource_usage_interval')
      should contain_cassandra__private__opscenter__setting('provisioning agent_install_timeout')
      should contain_cassandra__private__opscenter__setting('provisioning keyspace_timeout')
      should contain_cassandra__private__opscenter__setting('provisioning private_key_dir')
      should contain_cassandra__private__opscenter__setting('repair_service alert_on_repair_failure')
      should contain_cassandra__private__opscenter__setting('repair_service cluster_stabilization_period')
      should contain_cassandra__private__opscenter__setting('repair_service error_logging_window')
      should contain_cassandra__private__opscenter__setting('repair_service incremental_err_alert_threshold')
      should contain_cassandra__private__opscenter__setting('repair_service incremental_range_repair')
      should contain_cassandra__private__opscenter__setting('repair_service incremental_repair_tables')
      should contain_cassandra__private__opscenter__setting('repair_service ks_update_period')
      should contain_cassandra__private__opscenter__setting('repair_service log_directory')
      should contain_cassandra__private__opscenter__setting('repair_service log_length')
      should contain_cassandra__private__opscenter__setting('repair_service max_err_threshold')
      should contain_cassandra__private__opscenter__setting('repair_service max_parallel_repairs')
      should contain_cassandra__private__opscenter__setting('repair_service max_pending_repairs')
      should contain_cassandra__private__opscenter__setting('repair_service max_rotate')
      should contain_cassandra__private__opscenter__setting('repair_service min_repair_time')
      should contain_cassandra__private__opscenter__setting('repair_service min_throughput')
      should contain_cassandra__private__opscenter__setting('repair_service num_recent_throughputs')
      should contain_cassandra__private__opscenter__setting('repair_service persist_directory')
      should contain_cassandra__private__opscenter__setting('repair_service persist_period')
      should contain_cassandra__private__opscenter__setting('repair_service restart_period')
      should contain_cassandra__private__opscenter__setting('repair_service single_repair_timeout')
      should contain_cassandra__private__opscenter__setting('repair_service single_task_err_threshold')
      should contain_cassandra__private__opscenter__setting('repair_service snapshot_override')
      should contain_cassandra__private__opscenter__setting('request_tracker queue_size')
      should contain_cassandra__private__opscenter__setting('security config_encryption_active')
      should contain_cassandra__private__opscenter__setting('security config_encryption_key_name')
      should contain_cassandra__private__opscenter__setting('security config_encryption_key_path')
      should contain_cassandra__private__opscenter__setting('spark base_master_proxy_port')
      should contain_cassandra__private__opscenter__setting('stat_reporter initial_sleep')
      should contain_cassandra__private__opscenter__setting('stat_reporter interval')
      should contain_cassandra__private__opscenter__setting('stat_reporter report_file')
      should contain_cassandra__private__opscenter__setting('stat_reporter ssl_key')
      should contain_cassandra__private__opscenter__setting('ui default_api_timeout')
      should contain_cassandra__private__opscenter__setting('ui max_metrics_requests')
      should contain_cassandra__private__opscenter__setting('ui node_detail_refresh_delay')
      should contain_cassandra__private__opscenter__setting('ui storagemap_ttl')
      should contain_cassandra__private__opscenter__setting('webserver interface')
      should contain_cassandra__private__opscenter__setting('webserver log_path')
      should contain_cassandra__private__opscenter__setting('webserver port')
      should contain_cassandra__private__opscenter__setting('webserver ssl_certfile')
      should contain_cassandra__private__opscenter__setting('webserver ssl_keyfile')
      should contain_cassandra__private__opscenter__setting('webserver ssl_port')
      should contain_cassandra__private__opscenter__setting('webserver staticdir')
      should contain_cassandra__private__opscenter__setting('webserver sub_process_timeout')
      should contain_cassandra__private__opscenter__setting('webserver tarball_process_timeout')
    end
  end

  context 'Test params for cassandra::opscenter special cases.' do
    let :params do
      {
        authentication_method: 42,
        failover_configuration_directory: '/path/to'
      }
    end

    it do
      should contain_class('cassandra::opscenter').with('authentication_method' => 42,
                                                        'failover_configuration_directory' => '/path/to')
    end
  end

  context 'Test for cassandra::opscenter package.' do
    it do
      should contain_package('opscenter')
    end
  end

  context 'Test for cassandra::opscenter service.' do
    it do
      should contain_service('opscenterd')
    end
  end
end
