# frozen_string_literal: true

require 'spec_helper'

describe 'cassandra' do
  let :node do
    'foo.example.com'
  end

  on_supported_os.each do |os, os_facts|
    let(:facts) do
      os_facts
    end

    context 'on an unsupported OS' do
      let(:facts) do
        super().merge({
                        'os' => {
                          'family' => 'fakeLinux',
                        }
                      })
      end

      it { is_expected.to raise_error(Puppet::Error) }

      context 'with fail_on_non_supported_os => false' do
        let :params do
          {
            config_file_mode: '0755',
            config_path: '/etc/cassandra',
            fail_on_non_supported_os: false,
            package_name: 'cassandra',
            service_provider: 'base',
            systemctl: '/bin/true'
          }
        end

        it do
          expect(subject).to contain_file('/etc/cassandra/cassandra.yaml').with('mode' => '0755')
          expect(subject).to contain_service('cassandra').with(provider: 'base')
          expect(subject).to have_resource_count(6)
        end
      end
    end

    context "on #{os}" do
      let(:facts) do
        super().merge({
                        cassandrarelease: '4.0.0',
                      })
      end

      package_name = case os_facts[:os]['family']
                     when 'RedHat' then 'cassandra22'
                     else 'cassandra'
                     end

      systemctl_path = case os_facts[:os]['family']
                       when 'RedHat' then '/usr/bin/systemctl'
                       else '/bin/systemctl'
                       end

      systemctl_command = "#{systemctl_path} daemon-reload"
      systemctl_onlyif = "test -x #{systemctl_path}"

      config_path = case os_facts[:os]['family']
                    when 'Debian' then '/etc/cassandra'
                    when 'RedHat' then '/etc/cassandra/default.conf'
                    else '/bin/false'
                    end

      config_file_requires = case os_facts[:os]['family']
                             when 'RedHat' then 'Package[cassandra]'
                             when 'Debian' then ['User[cassandra]', 'File[/etc/cassandra]']
                             end

      config_path_requires = case os_facts[:os]['family']
                             when 'RedHat' then 'Package[cassandra]'
                             else []
                             end

      config_file_before = case os_facts[:os]['family']
                           when 'RedHat' then []
                           else 'Package[cassandra]'
                           end

      config_file = "#{config_path}/cassandra.yaml"
      snitch_properties_file = "#{config_path}/cassandra-rackdc.properties"

      context 'with default parameters' do
        it 'installs the cassandra package' do
          expect(subject).to contain_package('cassandra').with(
            ensure: 'present',
            name: package_name)
        end

        it 'contains cassandra class' do
          expect(subject).to contain_class('cassandra').only_with(
            baseline_settings: {},
            cassandra_2356_sleep_seconds: 5,
            cassandra_9822: false, # rubocop:disable Naming/VariableNumber
            cassandra_yaml_tmpl: 'cassandra/cassandra.yaml.erb',
            commitlog_directory_mode: '0750',
            manage_config_file: true,
            config_file_mode: '0644',
            config_path: config_path,
            data_file_directories_mode: '0750',
            dc: 'DC1',
            fail_on_non_supported_os: true,
            hints_directory_mode: '0750',
            package_ensure: 'present',
            package_name: package_name,
            rack: 'RAC1',
            rackdc_tmpl: 'cassandra/cassandra-rackdc.properties.erb',
            saved_caches_directory_mode: '0750',
            service_enable: true,
            service_name: 'cassandra',
            service_provider: nil,
            service_refresh: true,
            settings: {},
            snitch_properties_file: 'cassandra-rackdc.properties',
            systemctl: systemctl_path
          )
        end

        it 'creates cassandra user and group' do
          expect(subject).to contain_group('cassandra').with_ensure('present')

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
        end

        it 'creates cassandra service' do
          expect(subject).to contain_service('cassandra').with(
            ensure: nil,
            name: 'cassandra',
            enable: 'true'
          ).that_subscribes_to(
            [
              'File[/etc/cassandra/cassandra.yaml]',
              'File[/etc/cassandra/cassandra-rackdc.properties]',
              'Package[cassandra]'
            ]
          )
        end

        it 'contains CASSANDRA-2356 sleep' do
          expect(subject).to contain_exec('CASSANDRA-2356 sleep').
            with(
              command: '/bin/sleep 5',
              refreshonly: true,
              user: 'root'
            ).
            that_subscribes_to('Package[cassandra]').
            that_comes_before('Service[cassandra]')
        end

        it 'creates config file and path' do
          expect(subject).to contain_file(config_path).
            with(
              ensure: 'directory',
              group: 'cassandra',
              owner: 'cassandra',
              mode: '0755'
            ).that_requires(config_path_requires)

          expect(subject).to contain_file(config_file).
            with(
              ensure: 'file',
              owner: 'cassandra',
              group: 'cassandra',
              mode: '0644'
            ).
            that_comes_before(config_file_before).
            that_requires(config_file_requires)
        end

        it 'creates rackdc.properties correctly' do
          expect(subject).to contain_file(snitch_properties_file).
            with(
              ensure: 'file',
              owner: 'cassandra',
              group: 'cassandra',
              mode: '0644'
            ).
            that_requires(['File[/etc/cassandra]', 'User[cassandra]']).
            that_comes_before('Package[cassandra]').
            with_content(%r{^dc=DC1}).
            with_content(%r{^rack=RAC1$}).
            with_content(%r{^#dc_suffix=$}).
            with_content(%r{^# prefer_local=true$})
        end
      end

      context 'with data directories specified' do
        let :params do
          {
            commitlog_directory: '/var/lib/cassandra/commitlog',
            data_file_directories: ['/var/lib/cassandra/data'],
            hints_directory: '/var/lib/cassandra/hints',
            saved_caches_directory: '/var/lib/cassandra/saved_caches',
            settings: { 'cluster_name' => 'MyCassandraCluster' }
          }
        end

        it 'creates data directories' do
          expect(subject).to have_resource_count(13)
          expect(subject).to contain_file('/var/lib/cassandra/commitlog')
          expect(subject).to contain_file('/var/lib/cassandra/data')
          expect(subject).to contain_file('/var/lib/cassandra/hints')
          expect(subject).to contain_file('/var/lib/cassandra/saved_caches')
        end
      end

      if os_facts[:os]['family'] == 'RedHat'
        context 'with service provider set to init' do
          let :params do
            {
              service_provider: 'init'
            }
          end

          it 'executes chkconfig' do
            expect(subject).to have_resource_count(9)
            expect(subject).to contain_exec('/sbin/chkconfig --add cassandra').with(
              unless: '/sbin/chkconfig --list cassandra'
            ).
              that_requires('Package[cassandra]').
              that_comes_before('Service[cassandra]')
          end
        end
      end

      context 'with CASSANDRA-9822 => true' do
        let :params do
          {
            'cassandra_9822' => true
          }
        end

        it do
          expect(subject).to contain_file('/etc/init.d/cassandra').with(
            source: 'puppet:///modules/cassandra/CASSANDRA-9822/cassandra',
            mode: '0555'
          ).that_comes_before('Package[cassandra]')
        end
      end

      context 'with package_name => dse-full' do
        let :params do
          {
            package_ensure: '4.7.0-1',
            package_name: 'dse-full',
            config_path: '/etc/dse/cassandra',
            service_name: 'dse'
          }
        end

        it do
          expect(subject).to contain_file('/etc/dse/cassandra/cassandra.yaml').that_notifies('Service[cassandra]')
          expect(subject).to contain_file('/etc/dse/cassandra')

          expect(subject).to contain_file('/etc/dse/cassandra/cassandra-rackdc.properties').
            with(
              ensure: 'file',
              owner: 'cassandra',
              group: 'cassandra',
              mode: '0644'
            ).
            that_notifies('Service[cassandra]')

          expect(subject).to contain_package('cassandra').with(
            ensure: '4.7.0-1',
            name: 'dse-full'
          )
          expect(subject).to contain_service('cassandra').with_name('dse')
        end
      end

      context 'with service_ensure => stopped and service_enable => false' do
        let :params do
          {
            service_ensure: 'stopped',
            service_enable: 'false'
          }
        end

        it 'stops and disables cassandra service' do
          expect(subject).to contain_service('cassandra').
            with(ensure: 'stopped',
                 name: 'cassandra',
                 enable: 'false')
        end
      end

      if os_facts[:os]['family'] == 'RedHat'
        context 'with rackdc parameters' do
          snitch_properties_file = "#{config_path}/cassandra-topology.properties"
          let :params do
            {
              snitch_properties_file: snitch_properties_file,
              dc: 'NYC',
              rack: 'R101',
              dc_suffix: '_1_cassandra',
              prefer_local: 'true'
            }
          end

          it 'configures rackdc correctly' do
            expect(subject).to contain_file(snitch_properties_file).
              with_content(%r{^dc=NYC$}).
              with_content(%r{^rack=R101$}).
              with_content(%r{^dc_suffix=_1_cassandra$}).
              with_content(%r{^prefer_local=true$})
          end
        end
      end
    end
  end
end
