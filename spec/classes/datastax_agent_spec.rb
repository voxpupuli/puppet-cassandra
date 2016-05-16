require 'spec_helper'

describe 'cassandra::datastax_agent' do
  let(:pre_condition) do
    [
      'define ini_setting($ensure = nil,
         $path,
         $section,
         $key_val_separator       = nil,
         $setting,
         $value                   = nil) {}'
    ]
  end

  let!(:stdlib_stubs) do
    MockFunction.new('validate_hash') do |_f|
    end
    MockFunction.new('create_ini_settings') do |_f|
    end
  end

  context 'Test for cassandra::datastax_agent.' do
    it { should have_resource_count(3) }
    it do
      should contain_class('cassandra::datastax_agent').only_with(
        'defaults_file'        => '/etc/default/datastax-agent',
        'java_home'            => nil,
        'package_ensure'       => 'present',
        'package_name'         => 'datastax-agent',
        'service_ensure'       => 'running',
        'service_enable'       => true,
        'service_name'         => 'datastax-agent',
        # 'service_provider'     => nil,
        'service_systemd'      => false,
        'service_systemd_tmpl' => 'cassandra/datastax-agent.service.erb',
        'stomp_interface'      => nil,
        'local_interface'      => nil
      )
    end

    it do
      should contain_package('datastax-agent')
      should contain_service('datastax-agent')

      should contain_file('/var/lib/datastax-agent/conf/address.yaml')
        .with(
          owner: 'cassandra',
          group: 'cassandra'
        )
      should contain_file('/var/lib/datastax-agent/conf/address.yaml')
        .that_requires('Package[datastax-agent]')
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
        'ensure' => 'present',
        'path'   => '/etc/default/datastax-agent',
        'value'  => '/usr/lib/jvm/java-8-oracle'
      )
    end
  end

  context 'Systemd file can be activated on Red Hat' do
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

    it { should contain_file('/usr/lib/systemd/system/datastax-agent.service') }
    it { should contain_file('/var/run/datastax-agent') }

    it do
      is_expected.to contain_exec('datastax_agent_reload_systemctl').with(
        command: '/usr/bin/systemctl daemon-reload',
        refreshonly: true
      )
    end
  end

  context 'Systemd file can be activated on Debian' do
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

    it { should contain_file('/lib/systemd/system/datastax-agent.service') }
    it { should contain_file('/var/run/datastax-agent') }

    it do
      is_expected.to contain_exec('datastax_agent_reload_systemctl').with(
        command: '/bin/systemctl daemon-reload',
        refreshonly: true
      )
    end
  end

  context 'Test settings' do
    let :facts do
      {
        osfamily: 'Debian'
      }
    end

    let :params do
      {
        settings: {
          'agent_alias' => {
            'value' => 'foobar'
          },
          'stomp_interface' => {
            'value' => '192.168.0.42'
          },
          'async_pool_size' => {
            'ensure' => 'absent'
          }
        }
      }
    end
  end
end
