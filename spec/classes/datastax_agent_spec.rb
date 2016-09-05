require 'spec_helper'

describe 'cassandra::datastax_agent' do
  let(:pre_condition) do
    [
      'class cassandra() {}',
      'define ini_setting($ensure = nil,
         $path,
         $section,
         $key_val_separator       = nil,
         $setting,
         $value                   = nil) {}'
    ]
  end

  let!(:stdlib_stubs) do
    MockFunction.new('validate_hash', type: :statement) do |_f|
    end
    MockFunction.new('create_ini_settings', type: :statement) do |_f|
    end
  end

  context 'Test for cassandra::datastax_agent with defaults (RedHat).' do
    let :facts do
      {
        osfamily: 'RedHat'
      }
    end

    it do
      should have_resource_count(4)

      should contain_class('cassandra::datastax_agent').only_with(
        'defaults_file'        => '/etc/default/datastax-agent',
        'java_home'            => nil,
        'package_ensure'       => 'present',
        'package_name'         => 'datastax-agent',
        'service_ensure'       => 'running',
        'service_enable'       => true,
        'service_name'         => 'datastax-agent',
        'stomp_interface'      => nil,
        'local_interface'      => nil
      )

      should contain_package('datastax-agent').with(
        ensure: 'present',
        notify: 'Exec[datastax_agent_reload_systemctl]'
      ).that_notifies('Exec[datastax_agent_reload_systemctl]')

      should contain_exec('datastax_agent_reload_systemctl').only_with(
        command: '/usr/bin/systemctl daemon-reload',
        onlyif: 'test -x /usr/bin/systemctl',
        path: ['/usr/bin', '/bin'],
        refreshonly: true,
        notify: 'Service[datastax-agent]'
      ).that_notifies('Service[datastax-agent]')

      should contain_file('/var/lib/datastax-agent/conf/address.yaml')
        .with(
          owner: 'cassandra',
          group: 'cassandra',
          mode: '0640'
        ).that_requires('Package[datastax-agent]')

      should contain_service('datastax-agent').only_with(
        ensure: 'running',
        enable: true,
        name: 'datastax-agent'
      )
    end
  end

  context 'Test for cassandra::datastax_agent with defaults (Debian).' do
    let :facts do
      {
        osfamily: 'Debian'
      }
    end

    it do
      should contain_exec('datastax_agent_reload_systemctl').with(
        command: '/bin/systemctl daemon-reload',
        onlyif: 'test -x /bin/systemctl',
        path: ['/usr/bin', '/bin'],
        refreshonly: true
      ).that_notifies('Service[datastax-agent]')
    end
  end

  context 'Test that the JAVA_HOME can be set.' do
    let :params do
      {
        java_home: '/usr/lib/jvm/java-8-oracle'
      }
    end

    it do
      should contain_ini_setting('java_home').with(
        ensure: 'present',
        path: '/etc/default/datastax-agent',
        section: '',
        key_val_separator: '=',
        setting: 'JAVA_HOME',
        value: '/usr/lib/jvm/java-8-oracle'
      ).that_notifies('Service[datastax-agent]')
    end
  end

  context 'Test settings.' do
    let :params do
      {
        settings: {
          'agent_alias' => {
            'setting' => 'agent_alias',
            'value'   => 'foobar'
          },
          'stomp_interface' => {
            'setting' => 'stomp_interface',
            'value'   => 'localhost'
          },
          'async_pool_size' => {
            'ensure' => 'absent'
          }
        }
      }
    end

    it do
      should have_resource_count(4)
    end
  end
end
