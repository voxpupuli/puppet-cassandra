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

  context 'Systemd (Red Hat 6).' do
    let :facts do
      {
        osfamily: 'RedHat',
        operatingsystemmajrelease: 6
      }
    end

    it { should have_resource_count(256) }

    it do
      should contain_class('cassandra::opscenter').with_service_systemd(false)
    end
  end

  context 'Systemd (Red Hat 7).' do
    let :facts do
      {
        osfamily: 'RedHat',
        operatingsystemmajrelease: 7
      }
    end

    it { should have_resource_count(258) }

    it do
      should contain_class('cassandra::opscenter').with_service_systemd(true)
      should contain_exec('opscenter_reload_systemctl').with(refreshonly: true)
      should contain_file('/usr/lib/systemd/system/opscenterd.service')
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
    it { should have_resource_count(258) }

    it do
      should contain_exec('opscenter_reload_systemctl').with(refreshonly: true)
      should contain_file('/lib/systemd/system/opscenterd.service')
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

    it { should have_resource_count(256) }

    it do
      should contain_cassandra__private__opscenter__setting('agents agent_certfile')
    end

    it do
      should contain_cassandra__private__opscenter__setting('agents agent_keyfile')
    end

    it do
      should contain_cassandra__private__opscenter__setting('agents agent_keyfile_raw')
    end

    it do
      should contain_cassandra__private__opscenter__setting('agents config_sleep')
    end

    it do
      should contain_cassandra__private__opscenter__setting('agents fingerprint_throttle')
    end

    it do
      should contain_cassandra__private__opscenter__setting('agents incoming_interface')
    end

    it do
      should contain_cassandra__private__opscenter__setting('agents incoming_port')
    end

    it do
      should contain_cassandra__private__opscenter__setting('agents install_throttle')
    end

    it do
      should contain_cassandra__private__opscenter__setting('agents not_seen_threshold')
    end

    it do
      should contain_cassandra__private__opscenter__setting('agents path_to_deb')
    end

    it do
      should contain_cassandra__private__opscenter__setting('agents path_to_find_java')
    end

    it do
      should contain_cassandra__private__opscenter__setting('agents path_to_installscript')
    end

    it do
      should contain_cassandra__private__opscenter__setting('agents path_to_rpm')
    end

    it do
      should contain_cassandra__private__opscenter__setting('agents path_to_sudowrap')
    end

    it do
      should contain_cassandra__private__opscenter__setting('agents reported_interface')
    end

    it do
      should contain_cassandra__private__opscenter__setting('agents runs_sudo')
    end

    it do
      should contain_cassandra__private__opscenter__setting('agents scp_executable')
    end

    it do
      should contain_cassandra__private__opscenter__setting('agents ssh_executable')
    end

    it do
      should contain_cassandra__private__opscenter__setting('agents ssh_keygen_executable')
    end

    it do
      should contain_cassandra__private__opscenter__setting('agents ssh_keyscan_executable')
    end

    it do
      should contain_cassandra__private__opscenter__setting('agents ssh_port')
    end

    it do
      should contain_cassandra__private__opscenter__setting('agents ssh_sys_known_hosts_file')
    end

    it do
      should contain_cassandra__private__opscenter__setting('agents ssh_user_known_hosts_file')
    end

    it do
      should contain_cassandra__private__opscenter__setting('agents ssl_certfile')
    end

    it do
      should contain_cassandra__private__opscenter__setting('agents ssl_keyfile')
    end

    it do
      should contain_cassandra__private__opscenter__setting('agents tmp_dir')
    end

    it do
      should contain_cassandra__private__opscenter__setting('agents use_ssl')
    end

    it do
      should contain_cassandra__private__opscenter__setting('authentication audit_auth')
    end

    it do
      should contain_cassandra__private__opscenter__setting('authentication audit_pattern')
    end

    it do
      should contain_cassandra__private__opscenter__setting('authentication authentication_method')
    end

    it do
      should contain_cassandra__private__opscenter__setting('authentication enabled')
    end

    it do
      should contain_cassandra__private__opscenter__setting('authentication passwd_db')
    end

    it do
      should contain_cassandra__private__opscenter__setting('authentication timeout')
    end

    it do
      should contain_cassandra__private__opscenter__setting('cloud accepted_certs')
    end

    it do
      should contain_cassandra__private__opscenter__setting('clusters add_cluster_timeout')
    end

    it do
      should contain_cassandra__private__opscenter__setting('clusters startup_sleep')
    end

    it do
      should contain_cassandra__private__opscenter__setting('definitions auto_update')
    end

    it do
      should contain_cassandra__private__opscenter__setting('definitions definitions_dir')
    end

    it do
      should contain_cassandra__private__opscenter__setting('definitions download_filename')
    end

    it do
      should contain_cassandra__private__opscenter__setting('definitions download_host')
    end

    it do
      should contain_cassandra__private__opscenter__setting('definitions download_port')
    end

    it do
      should contain_cassandra__private__opscenter__setting('definitions hash_filename')
    end

    it do
      should contain_cassandra__private__opscenter__setting('definitions sleep')
    end

    it do
      should contain_cassandra__private__opscenter__setting('definitions ssl_certfile')
    end

    it do
      should contain_cassandra__private__opscenter__setting('definitions use_ssl')
    end

    it do
      should contain_cassandra__private__opscenter__setting('failover failover_configuration_directory')
    end

    it do
      should contain_cassandra__private__opscenter__setting('failover heartbeat_fail_window')
    end

    it do
      should contain_cassandra__private__opscenter__setting('failover heartbeat_period')
    end

    it do
      should contain_cassandra__private__opscenter__setting('failover heartbeat_reply_period')
    end

    it do
      should contain_cassandra__private__opscenter__setting('hadoop base_job_tracker_proxy_port')
    end

    it do
      should contain_cassandra__private__opscenter__setting('labs orbited_longpoll')
    end

    it do
      should contain_cassandra__private__opscenter__setting('ldap admin_group_name')
    end

    it do
      should contain_cassandra__private__opscenter__setting('ldap connection_timeout')
    end

    it do
      should contain_cassandra__private__opscenter__setting('ldap debug_ssl')
    end

    it do
      should contain_cassandra__private__opscenter__setting('ldap group_name_attribute')
    end

    it do
      should contain_cassandra__private__opscenter__setting('ldap group_search_base')
    end

    it do
      should contain_cassandra__private__opscenter__setting('ldap group_search_filter')
    end

    it do
      should contain_cassandra__private__opscenter__setting('ldap group_search_filter_with_dn')
    end

    it do
      should contain_cassandra__private__opscenter__setting('ldap group_search_type')
    end

    it do
      should contain_cassandra__private__opscenter__setting('ldap ldap_security')
    end

    it do
      should contain_cassandra__private__opscenter__setting('ldap opt_referrals')
    end

    it do
      should contain_cassandra__private__opscenter__setting('ldap protocol_version')
    end

    it do
      should contain_cassandra__private__opscenter__setting('ldap search_dn')
    end

    it do
      should contain_cassandra__private__opscenter__setting('ldap search_password')
    end

    it do
      should contain_cassandra__private__opscenter__setting('ldap server_host')
    end

    it do
      should contain_cassandra__private__opscenter__setting('ldap server_port')
    end

    it do
      should contain_cassandra__private__opscenter__setting('ldap ssl_cacert')
    end

    it do
      should contain_cassandra__private__opscenter__setting('ldap ssl_cert')
    end

    it do
      should contain_cassandra__private__opscenter__setting('ldap ssl_key')
    end

    it do
      should contain_cassandra__private__opscenter__setting('ldap tls_demand')
    end

    it do
      should contain_cassandra__private__opscenter__setting('ldap tls_reqcert')
    end

    it do
      should contain_cassandra__private__opscenter__setting('ldap uri_scheme')
    end

    it do
      should contain_cassandra__private__opscenter__setting('ldap user_memberof_attribute')
    end

    it do
      should contain_cassandra__private__opscenter__setting('ldap user_search_base')
    end

    it do
      should contain_cassandra__private__opscenter__setting('ldap user_search_filter')
    end

    it do
      should contain_cassandra__private__opscenter__setting('logging level')
    end

    it do
      should contain_cassandra__private__opscenter__setting('logging log_length')
    end

    it do
      should contain_cassandra__private__opscenter__setting('logging log_path')
    end

    it do
      should contain_cassandra__private__opscenter__setting('logging max_rotate')
    end

    it do
      should contain_cassandra__private__opscenter__setting('logging resource_usage_interval')
    end

    it do
      should contain_cassandra__private__opscenter__setting('provisioning agent_install_timeout')
    end

    it do
      should contain_cassandra__private__opscenter__setting('provisioning keyspace_timeout')
    end

    it do
      should contain_cassandra__private__opscenter__setting('provisioning private_key_dir')
    end

    it do
      should contain_cassandra__private__opscenter__setting('repair_service alert_on_repair_failure')
    end

    it do
      should contain_cassandra__private__opscenter__setting('repair_service cluster_stabilization_period')
    end

    it do
      should contain_cassandra__private__opscenter__setting('repair_service error_logging_window')
    end

    it do
      should contain_cassandra__private__opscenter__setting('repair_service incremental_err_alert_threshold')
    end

    it do
      should contain_cassandra__private__opscenter__setting('repair_service incremental_range_repair')
    end

    it do
      should contain_cassandra__private__opscenter__setting('repair_service incremental_repair_tables')
    end

    it do
      should contain_cassandra__private__opscenter__setting('repair_service ks_update_period')
    end

    it do
      should contain_cassandra__private__opscenter__setting('repair_service log_directory')
    end

    it do
      should contain_cassandra__private__opscenter__setting('repair_service log_length')
    end

    it do
      should contain_cassandra__private__opscenter__setting('repair_service max_err_threshold')
    end

    it do
      should contain_cassandra__private__opscenter__setting('repair_service max_parallel_repairs')
    end

    it do
      should contain_cassandra__private__opscenter__setting('repair_service max_pending_repairs')
    end

    it do
      should contain_cassandra__private__opscenter__setting('repair_service max_rotate')
    end

    it do
      should contain_cassandra__private__opscenter__setting('repair_service min_repair_time')
    end

    it do
      should contain_cassandra__private__opscenter__setting('repair_service min_throughput')
    end

    it do
      should contain_cassandra__private__opscenter__setting('repair_service num_recent_throughputs')
    end

    it do
      should contain_cassandra__private__opscenter__setting('repair_service persist_directory')
    end

    it do
      should contain_cassandra__private__opscenter__setting('repair_service persist_period')
    end

    it do
      should contain_cassandra__private__opscenter__setting('repair_service restart_period')
    end

    it do
      should contain_cassandra__private__opscenter__setting('repair_service single_repair_timeout')
    end

    it do
      should contain_cassandra__private__opscenter__setting('repair_service single_task_err_threshold')
    end

    it do
      should contain_cassandra__private__opscenter__setting('repair_service snapshot_override')
    end

    it do
      should contain_cassandra__private__opscenter__setting('request_tracker queue_size')
    end

    it do
      should contain_cassandra__private__opscenter__setting('security config_encryption_active')
    end

    it do
      should contain_cassandra__private__opscenter__setting('security config_encryption_key_name')
    end

    it do
      should contain_cassandra__private__opscenter__setting('security config_encryption_key_path')
    end

    it do
      should contain_cassandra__private__opscenter__setting('spark base_master_proxy_port')
    end

    it do
      should contain_cassandra__private__opscenter__setting('stat_reporter initial_sleep')
    end

    it do
      should contain_cassandra__private__opscenter__setting('stat_reporter interval')
    end

    it do
      should contain_cassandra__private__opscenter__setting('stat_reporter report_file')
    end

    it do
      should contain_cassandra__private__opscenter__setting('stat_reporter ssl_key')
    end

    it do
      should contain_cassandra__private__opscenter__setting('ui default_api_timeout')
    end

    it do
      should contain_cassandra__private__opscenter__setting('ui max_metrics_requests')
    end

    it do
      should contain_cassandra__private__opscenter__setting('ui node_detail_refresh_delay')
    end

    it do
      should contain_cassandra__private__opscenter__setting('ui storagemap_ttl')
    end

    it do
      should contain_cassandra__private__opscenter__setting('webserver interface')
    end

    it do
      should contain_cassandra__private__opscenter__setting('webserver log_path')
    end

    it do
      should contain_cassandra__private__opscenter__setting('webserver port')
    end

    it do
      should contain_cassandra__private__opscenter__setting('webserver ssl_certfile')
    end

    it do
      should contain_cassandra__private__opscenter__setting('webserver ssl_keyfile')
    end

    it do
      should contain_cassandra__private__opscenter__setting('webserver ssl_port')
    end

    it do
      should contain_cassandra__private__opscenter__setting('webserver staticdir')
    end

    it do
      should contain_cassandra__private__opscenter__setting('webserver sub_process_timeout')
    end

    it do
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
