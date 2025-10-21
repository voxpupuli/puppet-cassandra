# frozen_string_literal: true

require 'spec_helper'

describe 'cassandra' do
  let :node do
    'foo.example.com'
  end

  context 'on an unsupported OS with default parameters' do
    let(:facts) do
      {
        os: {
          family: 'Unknown',
          release: { full: '1.0' }
        }
      }
    end

    it { is_expected.to raise_error(Puppet::Error) }
  end

  context 'on an unsupported OS pleading tolerance' do
    let(:facts) do
      {
        os: {
          family: 'Unknown',
          release: { full: '1.0' }
        }
      }
    end
    let :params do
      {
        config_file_mode: '0755',
        config_path: '/etc/cassandra',
        fail_on_non_supported_os: false,
        package_name: 'cassandra',
        systemctl: '/bin/true'
      }
    end

    it do
      expect(subject).to contain_file('/etc/cassandra/cassandra.yaml').with('mode' => '0755')
      expect(subject).to contain_service('cassandra').with(provider: 'base')
      expect(subject).to have_resource_count(6)
    end
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      case facts[:os]['family']
      when 'RedHat'
        context 'with default parameters' do
          it do
            expect(subject).to contain_package('cassandra').with(
              ensure: 'present',
              name: 'cassandra'
            ).that_notifies('Exec[cassandra_reload_systemctl]')

            expect(subject).to contain_exec('cassandra_reload_systemctl').only_with(
              command: '/usr/bin/systemctl daemon-reload',
              onlyif: 'test -x /usr/bin/systemctl',
              path: ['/usr/bin', '/bin'],
              refreshonly: true
            )

            expect(subject).to contain_file('/etc/cassandra/default.conf').with(
              ensure: 'directory',
              group: 'cassandra',
              owner: 'cassandra',
              mode: '0755'
            ).that_requires('Package[cassandra]')

            expect(subject).to contain_file('/etc/cassandra/default.conf/cassandra.yaml').
              with(
                ensure: 'file',
                owner: 'cassandra',
                group: 'cassandra',
                mode: '0644'
              ).
              that_requires('Package[cassandra]')

            expect(subject).to contain_class('cassandra').only_with(
              baseline_settings: {},
              cassandra_yaml_tmpl: 'cassandra/cassandra.yaml.erb',
              commitlog_directory_mode: '0750',
              manage_config_file: true,
              config_file_mode: '0644',
              config_path: '/etc/cassandra/default.conf',
              data_file_directories_mode: '0750',
              dc: 'DC1',
              fail_on_non_supported_os: true,
              hints_directory_mode: '0750',
              package_ensure: 'present',
              package_name: 'cassandra',
              rack: 'RAC1',
              rackdc_tmpl: 'cassandra/cassandra-rackdc.properties.erb',
              saved_caches_directory_mode: '0750',
              service_enable: true,
              service_name: 'cassandra',
              service_refresh: true,
              settings: {},
              snitch_properties_file: 'cassandra-rackdc.properties',
              systemctl: '/usr/bin/systemctl'
            )

            expect(subject).to contain_file('/etc/cassandra/default.conf/cassandra-rackdc.properties').
              with_content(%r{^dc=DC1}).
              with_content(%r{^rack=RAC1$}).
              with_content(%r{^#dc_suffix=$}).
              with_content(%r{^# prefer_local=true$})
          end
        end

        context 'with dc and rack properties.' do
          let :params do
            {
              snitch_properties_file: 'cassandra-topology.properties',
              dc: 'NYC',
              rack: 'R101',
              dc_suffix: '_1_cassandra',
              prefer_local: 'true'
            }
          end

          it do
            expect(subject).to contain_file('/etc/cassandra/default.conf/cassandra-topology.properties').
              with_content(%r{^dc=NYC$}).
              with_content(%r{^rack=R101$}).
              with_content(%r{^dc_suffix=_1_cassandra$}).
              with_content(%r{^prefer_local=true$})
          end
        end
      when 'Debian'
        context 'with default parameters' do
          it do
            expect(subject).to contain_class('cassandra')
            expect(subject).to contain_group('cassandra').with_ensure('present')

            expect(subject).to contain_package('cassandra').with(
              ensure: 'present',
              name: 'cassandra'
            ).that_notifies('Exec[cassandra_reload_systemctl]')

            expect(subject).to contain_exec('cassandra_reload_systemctl').only_with(
              command: '/bin/systemctl daemon-reload',
              onlyif: 'test -x /bin/systemctl',
              path: ['/usr/bin', '/bin'],
              refreshonly: true
            )

            expect(subject).to contain_service('cassandra').with(
              ensure: nil,
              name: 'cassandra',
              enable: 'true'
            )

            expect(subject).to contain_exec('CASSANDRA-2356 sleep').
              with(
                command: '/bin/sleep 5',
                refreshonly: true,
                user: 'root'
              ).
              that_subscribes_to('Package[cassandra]').
              that_comes_before('Service[cassandra]')

            expect(subject).to contain_user('cassandra').
              with(
                ensure: 'present',
                comment: 'Cassandra database,,,',
                gid: 'cassandra',
                home: '/var/lib/cassandra',
                shell: '/bin/false',
                managehome: true
              ).
              that_requires('Group[cassandra]')

            expect(subject).to contain_file('/etc/cassandra').with(
              ensure: 'directory',
              group: 'cassandra',
              owner: 'cassandra',
              mode: '0755'
            )

            expect(subject).to contain_file('/etc/cassandra/cassandra.yaml').
              with(
                ensure: 'file',
                owner: 'cassandra',
                group: 'cassandra',
                mode: '0644'
              ).
              that_comes_before('Package[cassandra]').
              that_requires(['User[cassandra]', 'File[/etc/cassandra]'])

            expect(subject).to contain_file('/etc/cassandra/cassandra-rackdc.properties').
              with(
                ensure: 'file',
                owner: 'cassandra',
                group: 'cassandra',
                mode: '0644'
              ).
              that_requires(['File[/etc/cassandra]', 'User[cassandra]']).
              that_comes_before('Package[cassandra]')

            expect(subject).to contain_service('cassandra').
              that_subscribes_to(
                [
                  'File[/etc/cassandra/cassandra.yaml]',
                  'File[/etc/cassandra/cassandra-rackdc.properties]',
                  'Package[cassandra]'
                ]
              )

            expect(subject).to contain_file('/etc/cassandra/cassandra-rackdc.properties').
              with_content(%r{^dc=DC1}).
              with_content(%r{^rack=RAC1$}).
              with_content(%r{^#dc_suffix=$}).
              with_content(%r{^# prefer_local=true$})
          end
        end

        context 'with dc and rack properties.' do
          let :params do
            {
              snitch_properties_file: 'cassandra-topology.properties',
              dc: 'NYC',
              rack: 'R101',
              dc_suffix: '_1_cassandra',
              prefer_local: 'true'
            }
          end

          it do
            expect(subject).to contain_file('/etc/cassandra/cassandra-topology.properties').
              with_content(%r{^dc=NYC$}).
              with_content(%r{^rack=R101$}).
              with_content(%r{^dc_suffix=_1_cassandra$}).
              with_content(%r{^prefer_local=true$})
          end
        end
      end

      context 'with ensure cassandra service stopped and disabled.' do
        let :params do
          {
            service_ensure: 'stopped',
            service_enable: 'false'
          }
        end

        it do
          expect(subject).to contain_service('cassandra').
            with(ensure: 'stopped',
                 name: 'cassandra',
                 enable: 'false')
        end
      end
    end
  end
end
