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

  context 'Test the default parameters (RedHat)' do
    let :facts do
      {
        osfamily: 'RedHat'
      }
    end

    it do
      should contain_package('cassandra').with(
        ensure: 'present',
        name: 'cassandra22'
      ).that_notifies('Exec[cassandra_reload_systemctl]')

      should contain_exec('cassandra_reload_systemctl').only_with(
        command: '/usr/bin/systemctl daemon-reload',
        onlyif: 'test -x /usr/bin/systemctl',
        path: ['/usr/bin', '/bin'],
        refreshonly: true
      )

      should contain_file('/etc/cassandra/default.conf').with(
        ensure: 'directory',
        group: 'cassandra',
        owner: 'cassandra',
        mode: '0755'
      ).that_requires('Package[cassandra]')

      should contain_file('/etc/cassandra/default.conf/cassandra.yaml')
        .with(
          ensure: 'present',
          owner: 'cassandra',
          group: 'cassandra',
          mode: '0644'
        )
        .that_requires('Package[cassandra]')

      should contain_class('cassandra').only_with(
        cassandra_2356_sleep_seconds: 5,
        cassandra_9822: false,
        cassandra_yaml_tmpl: 'cassandra/cassandra.yaml.erb',
        config_file_mode: '0644',
        config_path: '/etc/cassandra/default.conf',
        dc: 'DC1',
        dc_suffix: nil,
        fail_on_non_supported_os: true,
        package_ensure: 'present',
        package_name: 'cassandra22',
        rack: 'RAC1',
        rackdc_tmpl: 'cassandra/cassandra-rackdc.properties.erb',
        service_enable: true,
        # service_ensure: nil,
        service_name: 'cassandra',
        service_provider: nil,
        service_refresh: true,
        settings: {}
      )
    end
  end

  context 'On RedHat 7 with service provider set to init.' do
    let :facts do
      {
        osfamily: 'RedHat',
        operatingsystemmajrelease: 7
      }
    end

    let :params do
      {
        service_provider: 'init'
      }
    end

    it do
      should have_resource_count(7)
      should contain_exec('/sbin/chkconfig --add cassandra').with(
        unless: '/sbin/chkconfig --list cassandra'
      )
        .that_requires('Package[cassandra]')
        .that_comes_before('Service[cassandra]')
    end
  end

  context 'On a Debian OS with defaults for all parameters' do
    let :facts do
      {
        osfamily: 'Debian'
      }
    end

    it do
      should contain_class('cassandra')
      should contain_group('cassandra').with_ensure('present')

      should contain_package('cassandra').with(
        ensure: 'present',
        name: 'cassandra'
      ).that_notifies('Exec[cassandra_reload_systemctl]')

      should contain_exec('cassandra_reload_systemctl').only_with(
        command: '/bin/systemctl daemon-reload',
        onlyif: 'test -x /bin/systemctl',
        path: ['/usr/bin', '/bin'],
        refreshonly: true
      )

      should contain_service('cassandra').with(
        ensure: nil,
        name: 'cassandra',
        enable: 'true'
      )

      should contain_exec('CASSANDRA-2356 sleep')
        .with(
          command: '/bin/sleep 5',
          refreshonly: true,
          user: 'root'
        )
        .that_subscribes_to('Package[cassandra]')
        .that_comes_before('Service[cassandra]')

      should contain_user('cassandra')
        .with(
          ensure: 'present',
          comment: 'Cassandra database,,,',
          gid: 'cassandra',
          home: '/var/lib/cassandra',
          shell: '/bin/false',
          managehome: true
        )
        .that_requires('Group[cassandra]')

      should contain_file('/etc/cassandra').with(
        ensure: 'directory',
        group: 'cassandra',
        owner: 'cassandra',
        mode: '0755'
      )

      should contain_file('/etc/cassandra/cassandra.yaml')
        .with(
          ensure: 'present',
          owner: 'cassandra',
          group: 'cassandra',
          mode: '0644'
        )
        .that_comes_before('Package[cassandra]')
        .that_requires(['User[cassandra]', 'File[/etc/cassandra]'])

      should contain_file('/etc/cassandra/cassandra-rackdc.properties')
        .with(
          ensure: 'file',
          owner: 'cassandra',
          group: 'cassandra',
          mode: '0644'
        )
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
      should contain_file('/etc/init.d/cassandra').with(
        source: 'puppet:///modules/cassandra/CASSANDRA-9822/cassandra',
        mode: '0555'
      ).that_comes_before('Package[cassandra]')
    end
  end

  context 'Install DSE on a Red Hat family OS.' do
    let :facts do
      {
        osfamily: 'RedHat'
      }
    end

    let :params do
      {
        package_ensure: '4.7.0-1',
        package_name: 'dse-full',
        config_path: '/etc/dse/cassandra',
        service_name: 'dse'
      }
    end

    it do
      should contain_file('/etc/dse/cassandra/cassandra.yaml').that_notifies('Service[cassandra]')
      should contain_file('/etc/dse/cassandra')

      should contain_file('/etc/dse/cassandra/cassandra-rackdc.properties')
        .with(
          ensure: 'file',
          owner: 'cassandra',
          group: 'cassandra',
          mode: '0644'
        )
        .that_notifies('Service[cassandra]')

      should contain_package('cassandra').with(
        ensure: '4.7.0-1',
        name: 'dse-full'
      )
      is_expected.to contain_service('cassandra').with_name('dse')
    end
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
      should contain_file('/etc/cassandra/cassandra.yaml').with('mode' => '0755')
      should contain_service('cassandra').with(provider: 'base')
      should have_resource_count(6)
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
        .with(ensure: 'stopped',
              name: 'cassandra',
              enable: 'false')
    end
  end

  context 'Test the dc and rack properties with defaults (Debian).' do
    let :facts do
      {
        osfamily: 'Debian'
      }
    end

    it do
      should contain_file('/etc/cassandra/cassandra-rackdc.properties')
        .with_content(/^dc=DC1/)
        .with_content(/^rack=RAC1$/)
        .with_content(/^#dc_suffix=$/)
        .with_content(/^# prefer_local=true$/)
    end
  end

  context 'Test the dc and rack properties with defaults (RedHat).' do
    let :facts do
      {
        osfamily: 'RedHat'
      }
    end

    it do
      should contain_file('/etc/cassandra/default.conf/cassandra-rackdc.properties')
        .with_content(/^dc=DC1/)
        .with_content(/^rack=RAC1$/)
        .with_content(/^#dc_suffix=$/)
        .with_content(/^# prefer_local=true$/)
    end
  end

  context 'Test the dc and rack properties.' do
    let :facts do
      {
        osfamily: 'RedHat'
      }
    end

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
      should contain_file('/etc/cassandra/default.conf/cassandra-topology.properties')
        .with_content(/^dc=NYC$/)
        .with_content(/^rack=R101$/)
        .with_content(/^dc_suffix=_1_cassandra$/)
        .with_content(/^prefer_local=true$/)
    end
  end
end
