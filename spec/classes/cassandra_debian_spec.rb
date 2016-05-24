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
    it { should contain_file('/etc/cassandra/cassandra.yaml') }
    it { should contain_package('cassandra') }
    it { is_expected.to contain_service('cassandra') }
    it { is_expected.not_to contain_class('apt') }
    it { is_expected.not_to contain_class('apt::update') }
    it { is_expected.not_to contain_apt__key('datastaxkey') }
    it { is_expected.not_to contain_apt__source('datastax') }
    it { is_expected.not_to contain_exec('update-cassandra-repos') }
    it { should contain_exec('CASSANDRA-2356 sleep') }
    it { should contain_file('/etc/cassandra').with_ensure('directory') }
  end

  context 'On a Debian OS with manage_dsc_repo set to true' do
    let :facts do
      {
        osfamily: 'Debian',
        lsbdistid: 'Ubuntu',
        lsbdistrelease: '14.04'
      }
    end

    let :params do
      {
        manage_dsc_repo: true,
        service_name: 'foobar_service'
      }
    end

    it { should contain_class('apt') }
    it { should contain_class('apt::update') }

    it do
      is_expected.to contain_apt__key('datastaxkey')
        .with('id' => '7E41C00F85BFC1706C4FFFB3350200F2B999A372',
              'source' => 'http://debian.datastax.com/debian/repo_key')
    end

    it do
      is_expected.to contain_apt__source('datastax')
        .with('location' => 'http://debian.datastax.com/community',
              'comment'  => 'DataStax Repo for Apache Cassandra',
              'release'  => 'stable')
    end

    it { is_expected.to contain_exec('update-cassandra-repos') }
    it { is_expected.to contain_service('cassandra') }
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

    it { is_expected.to contain_file('/etc/init.d/cassandra') }
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

    it { should contain_file('/lib/systemd/system/cassandra.service') }

    it do
      should contain_exec('cassandra_reload_systemctl').with(
        command: '/bin/systemctl daemon-reload',
        refreshonly: true
      )
    end
  end
end
