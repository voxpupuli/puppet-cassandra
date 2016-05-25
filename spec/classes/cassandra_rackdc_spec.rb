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

  context 'Test the dc and rack properties with defaults (Debian).' do
    let :facts do
      {
        osfamily: 'Debian'
      }
    end

    it do
      should contain_file('/etc/cassandra/cassandra-rackdc.properties')
        .with_content(/^dc=DC1/)
      should contain_file('/etc/cassandra/cassandra-rackdc.properties')
        .with_content(/^rack=RAC1$/)
      should contain_file('/etc/cassandra/cassandra-rackdc.properties')
        .with_content(/^#dc_suffix=$/)
      should contain_file('/etc/cassandra/cassandra-rackdc.properties')
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
      should contain_file('/etc/cassandra/default.conf/cassandra-rackdc.properties')
        .with_content(/^rack=RAC1$/)
      should contain_file('/etc/cassandra/default.conf/cassandra-rackdc.properties')
        .with_content(/^#dc_suffix=$/)
      should contain_file('/etc/cassandra/default.conf/cassandra-rackdc.properties')
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
      should contain_file('/etc/cassandra/default.conf/cassandra-topology.properties')
        .with_content(/^rack=R101$/)
      should contain_file('/etc/cassandra/default.conf/cassandra-topology.properties')
        .with_content(/^dc_suffix=_1_cassandra$/)
      should contain_file('/etc/cassandra/default.conf/cassandra-topology.properties')
        .with_content(/^prefer_local=true$/)
    end
  end
end
