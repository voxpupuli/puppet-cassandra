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

  context 'On a Debian OS with defaults for all parameters' do
    let :facts do
      {
        osfamily: 'Debian'
      }
    end

    it { should contain_class('cassandra') }
    it do
      should contain_service('cassandra').with('ensure' => 'running',
                                               'enable' => 'true')
    end

    it { should contain_package('cassandra') }
    it { is_expected.to contain_service('cassandra') }
    it { is_expected.not_to contain_class('apt') }
    it { is_expected.not_to contain_class('apt::update') }
    it { is_expected.not_to contain_apt__key('datastaxkey') }
    it { is_expected.not_to contain_apt__source('datastax') }
    it { is_expected.not_to contain_exec('update-cassandra-repos') }
    it { should contain_file('/etc/cassandra').with_ensure('directory') }

    it do
      should contain_exec('CASSANDRA-2356 sleep')
        .that_comes_before('Service[cassandra]')
        .that_subscribes_to('Package[cassandra]')

      should contain_group('cassandra')
      should contain_user('cassandra')
        .that_requires('Group[cassandra]')

      should contain_file('/etc/cassandra/cassandra.yaml')
        .that_comes_before('Package[cassandra]')
        .that_requires(['User[cassandra]', 'File[/etc/cassandra]'])

      should contain_file('/etc/cassandra/cassandra-rackdc.properties')
        .that_requires(['File[/etc/cassandra]', 'User[cassandra]'])
        .that_comes_before('Package[cassandra]')

      should contain_service('cassandra')
        .that_subscribes_to(
          [
            'File[/etc/cassandra/cassandra.yaml]',
            'File[/etc/cassandra/cassandra-rackdc.properties]',
            'Package[cassandra]'
          ]
        )
    end
  end

  context 'On Debian with service_refresh set to false.' do
    let :facts do
      {
        osfamily: 'Debian'
      }
    end

    let :params do
      {
        service_refresh: false
      }
    end

    it do
      should contain_service('cassandra')
        .that_requires(
          [
            'File[/etc/cassandra/cassandra.yaml]',
            'File[/etc/cassandra/cassandra-rackdc.properties]',
            'Package[cassandra]'
          ]
        )
    end
  end

  context 'CASSANDRA-9822 not activated on Debian (default)' do
    let :facts do
      {
        osfamily: 'Debian',
        lsbdistid: 'Ubuntu',
        lsbdistrelease: '14.04'
      }
    end
    it do
      is_expected.not_to contain_file('/etc/init.d/cassandra')
        .with_mode('0555')
    end
  end

  context 'CASSANDRA-9822 activated on Debian' do
    let :facts do
      {
        osfamily: 'Debian',
        lsbdistid: 'Ubuntu',
        lsbdistrelease: '14.04'
      }
    end

    let :params do
      {
        cassandra_9822: true
      }
    end

    it do
      should contain_file('/etc/init.d/cassandra').that_comes_before('Package[cassandra]')
    end
  end
end
