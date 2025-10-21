# frozen_string_literal: true

require 'spec_helper'

describe 'cassandra' do
  describe 'config' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        it { is_expected.to compile.with_all_deps }

        case facts[:os]['family']
        when 'RedHat'
          context 'with default parameters' do
            it do
              is_expected.to contain_file('/etc/cassandra/default.conf').with(
                ensure: 'directory',
                owner: 'cassandra',
                group: 'cassandra',
                mode: '0755'
              )
              is_expected.to contain_file('/etc/cassandra/default.conf/cassandra.yaml').with(
                ensure: 'file',
                owner: 'cassandra',
                group: 'cassandra',
                mode: '0644',
                content: %r{--- {}}
              )
              is_expected.to contain_file('/etc/cassandra/default.conf/cassandra-rackdc.properties').with(
                ensure: 'file',
                owner: 'cassandra',
                group: 'cassandra',
                mode: '0644',
                content: %r{dc=DC1}
              )
            end
          end

          context 'with snitch parameters' do
            let(:params) do
              {
                dc: 'DC2',
                rack: 'RAC2',
                prefer_local: false,
              }
            end

            it do
              is_expected.to contain_file('/etc/cassandra/default.conf/cassandra-rackdc.properties').
                with(ensure: 'file', owner: 'cassandra', group: 'cassandra', mode: '0644').
                with_content(%r{^dc=DC2$}).
                with_content(%r{^rack=RAC2$}).
                with_content(%r{^prefer_local=false$})
            end
          end

          context 'with manage_config_file => false' do
            let(:params) do
              {
                manage_config_file: false
              }
            end

            it { is_expected.not_to contain_file('/etc/cassandra/default.conf/cassandra.yaml') }
          end

          context 'with baseline_settings and settings' do
            let(:params) do
              {
                baseline_settings: { 'authenticator' => 'AllowAllAuthenticator', 'cluster_name' => 'Test Cluster' },
                settings: { 'cluster_name' => 'Prod Cluster', 'num_tokens' => 256 },
              }
            end

            it do
              is_expected.to contain_file('/etc/cassandra/default.conf/cassandra.yaml').
                with_content(%r{^authenticator: AllowAllAuthenticator$}).
                with_content(%r{^cluster_name: Prod Cluster$}).
                with_content(%r{^num_tokens: 256$})
            end
          end

          context 'with baseline_settings, settings, hints_directory and saved_caches_directory' do
            let(:params) do
              {
                baseline_settings: { 'cluster_name' => 'Test Cluster', 'hints_directory' => '/tmp/hints' },
                settings: { 'cluster_name' => 'Prod Cluster', 'num_tokens' => 256, 'hints_directory' => '/tmp/other_hints' },
                hints_directory: '/var/hints',
                saved_caches_directory: '/var/saved_caches',
              }
            end

            it { is_expected.to contain_file('/var/hints').with(ensure: 'directory', owner: 'cassandra', group: 'cassandra', mode: '0750') }
            it { is_expected.to contain_file('/var/saved_caches').with(ensure: 'directory', owner: 'cassandra', group: 'cassandra', mode: '0750') }

            it do
              is_expected.to contain_file('/etc/cassandra/default.conf/cassandra.yaml').
                with_content(%r{^cluster_name: Prod Cluster$}).
                with_content(%r{^num_tokens: 256$}).
                with_content(%r{^hints_directory: "/var/hints"$}).
                with_content(%r{^saved_caches_directory: "/var/saved_caches"$})
            end
          end

          context 'with hints_directory in settings' do
            let(:params) do
              {
                baseline_settings: { 'cluster_name' => 'Test Cluster' },
                settings: { 'cluster_name' => 'Prod Cluster', 'num_tokens' => 256, 'hints_directory' => '/tmp/other_hints' },
              }
            end

            it { is_expected.not_to contain_file('/tmp/other_hints') }

            it do
              is_expected.to contain_file('/etc/cassandra/default.conf/cassandra.yaml').
                with_content(%r{^cluster_name: Prod Cluster$}).
                with_content(%r{^num_tokens: 256$}).
                with_content(%r{^hints_directory: "/tmp/other_hints"$})
            end
          end
        when 'Debian'
          context 'with default parameters' do
            it do
              is_expected.to contain_file('/etc/cassandra').with(
                ensure: 'directory',
                owner: 'cassandra',
                group: 'cassandra',
                mode: '0755'
              )
              is_expected.to contain_file('/etc/cassandra/cassandra.yaml').with(
                ensure: 'file',
                owner: 'cassandra',
                group: 'cassandra',
                mode: '0644',
                content: %r{--- {}}
              )
              is_expected.to contain_file('/etc/cassandra/cassandra-rackdc.properties').with(
                ensure: 'file',
                owner: 'cassandra',
                group: 'cassandra',
                mode: '0644',
                content: %r{rack=RAC1}
              )
            end
          end

          context 'with snitch parameters' do
            let(:params) do
              {
                dc: 'DC2',
                rack: 'RAC2',
                prefer_local: false,
              }
            end

            it do
              is_expected.to contain_file('/etc/cassandra/cassandra-rackdc.properties').
                with(ensure: 'file', owner: 'cassandra', group: 'cassandra', mode: '0644').
                with_content(%r{^dc=DC2$}).
                with_content(%r{^rack=RAC2$}).
                with_content(%r{^prefer_local=false$})
            end
          end

          context 'with manage_config_file => false' do
            let(:params) do
              {
                manage_config_file: false
              }
            end

            it { is_expected.not_to contain_file('/etc/cassandra/cassandra.yaml') }
          end

          context 'with baseline_settings and settings' do
            let(:params) do
              {
                baseline_settings: { 'authorizer' => 'AllowAllAuthorizer', 'cluster_name' => 'Test Cluster' },
                settings: { 'cluster_name' => 'Prod Cluster', 'num_tokens' => 500 },
              }
            end

            it do
              is_expected.to contain_file('/etc/cassandra/cassandra.yaml').
                with_content(%r{^authorizer: AllowAllAuthorizer$}).
                with_content(%r{^cluster_name: Prod Cluster$}).
                with_content(%r{^num_tokens: 500$})
            end
          end

          context 'with baseline_settings, settings, hints_directory and saved_caches_directory' do
            let(:params) do
              {
                baseline_settings: { 'cluster_name' => 'Test Cluster', 'save_caches_directory' => '/tmp/caches' },
                settings: { 'cluster_name' => 'Prod Cluster', 'num_tokens' => 256, 'save_caches_directory' => '/tmp/other_caches' },
                hints_directory: '/var/hints',
                saved_caches_directory: '/var/saved_caches',
              }
            end

            it { is_expected.to contain_file('/var/hints').with(ensure: 'directory', owner: 'cassandra', group: 'cassandra', mode: '0750') }
            it { is_expected.to contain_file('/var/saved_caches').with(ensure: 'directory', owner: 'cassandra', group: 'cassandra', mode: '0750') }

            it do
              is_expected.to contain_file('/etc/cassandra/cassandra.yaml').
                with_content(%r{^cluster_name: Prod Cluster$}).
                with_content(%r{^num_tokens: 256$}).
                with_content(%r{^hints_directory: "/var/hints"$}).
                with_content(%r{^saved_caches_directory: "/var/saved_caches"$})
            end
          end

          context 'with commitlog_directory in settings' do
            let(:params) do
              {
                baseline_settings: { 'cluster_name' => 'Test Cluster' },
                settings: { 'cluster_name' => 'Prod Cluster', 'num_tokens' => 256, 'commitlog_directory' => '/tmp/commits' },
              }
            end

            it { is_expected.not_to contain_file('/tmp/commits') }

            it do
              is_expected.to contain_file('/etc/cassandra/cassandra.yaml').
                with_content(%r{^cluster_name: Prod Cluster$}).
                with_content(%r{^num_tokens: 256$}).
                with_content(%r{^commitlog_directory: "/tmp/commits"$})
            end
          end
        end

        context 'with data_file_directories => [/var/cassandra/data1, /var/cassandra/data2]' do
          let(:params) do
            {
              data_file_directories: ['/var/cassandra/data1', '/var/cassandra/data2']
            }
          end

          it { is_expected.to contain_file('/var/cassandra/data1').with(ensure: 'directory', owner: 'cassandra', group: 'cassandra', mode: '0750') }
          it { is_expected.to contain_file('/var/cassandra/data2').with(ensure: 'directory', owner: 'cassandra', group: 'cassandra', mode: '0750') }
        end
      end
    end
  end
end
