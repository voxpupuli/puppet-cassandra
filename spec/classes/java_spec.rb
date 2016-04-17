require 'spec_helper'
describe 'cassandra::java' do
  let(:pre_condition) do
    [
      'class apt () {}',
      'class apt::update () {}',
      'define apt::key ($id, $server) {}',
      'define apt::source ($location, $comment, $release, $repos) {}'
    ]
  end

  context 'On a RedHat OS with defaults for all parameters' do
    let :facts do
      {
        osfamily: 'RedHat'
      }
    end

    it do
      should contain_class('cassandra::java')
    end

    it { should contain_package('java-1.8.0-openjdk-headless') }
    it { should contain_package('jna') }
  end

  context 'On a RedHat OS with ensure set.' do
    let :facts do
      {
        osfamily: 'RedHat'
      }
    end
    let :params do
      {
        ensure: '2.1.13-1'
      }
    end

    it do
      # rubocop:disable Metrics/LineLength
      should contain_package('java-1.8.0-openjdk-headless').with_ensure('2.1.13-1')
      should contain_cassandra__private__deprecation_warning('cassandra::java::ensure')
      # rubocop:enable Metrics/LineLength
    end
  end

  context 'On a Debian OS with defaults for all parameters' do
    let :facts do
      {
        osfamily: 'Debian'
      }
    end

    it { should contain_class('cassandra::java') }
    it { should contain_package('openjdk-7-jre-headless') }
    it { should contain_package('libjna-java') }
    it { should have_resource_count(2) }
  end

  context 'On a Debian OS with package_ensure set' do
    let :facts do
      {
        osfamily: 'Debian'
      }
    end
    let :params do
      {
        package_ensure: '2.1.13'
      }
    end

    # rubocop:disable Metrics/LineLength
    it { should contain_package('openjdk-7-jre-headless').with_ensure('2.1.13') }
    # rubocop:enable Metrics/LineLength
  end

  context 'With both ensure and package_ensure set differently (RedHat)' do
    let :facts do
      {
        osfamily: 'RedHat'
      }
    end
    let :params do
      {
        package_ensure: '2.1.13-1',
        ensure: 'latest'
      }
    end

    it { should raise_error(Puppet::Error) }
  end

  context 'With both ensure and package_ensure set the same (Debian)' do
    let :facts do
      {
        osfamily: 'Debian'
      }
    end
    let :params do
      {
        ensure: '2.1.13',
        package_ensure: '2.1.13'
      }
    end

    # rubocop:disable Metrics/LineLength
    it { should contain_package('openjdk-7-jre-headless').with_ensure('2.1.13') }
    # rubocop:enable Metrics/LineLength
  end

  context 'With package names set to foobar' do
    let :params do
      {
        package_name: 'foobar-java',
        ensure: '42',
        jna_package_name: 'foobar-jna',
        jna_ensure: 'latest'
      }
    end

    it do
      should contain_package('foobar-java').with(ensure: 42)
    end

    it do
      should contain_package('foobar-jna').with(ensure: 'latest')
    end
  end

  context 'Ensure that a YUM repo can be specified.' do
    let :facts do
      {
        osfamily: 'RedHat'
      }
    end

    let :params do
      {
        yumrepo: {
          'ACME' => {
            'baseurl' => 'http://yum.acme.org/repos',
            'descr'   => 'YUM Repository for ACME Products'
          }
        }
      }
    end

    it do
      should contain_yumrepo('ACME').with(
        baseurl: 'http://yum.acme.org/repos',
        descr: 'YUM Repository for ACME Products'
      )
    end
  end

  context 'Ensure that Apt key and source can be specified.' do
    let :facts do
      {
        osfamily: 'Debian'
      }
    end

    let :params do
      {
        aptkey: {
          'openjdk-r' => {
            'id'     => 'DA1A4A13543B466853BAF164EB9B1D8886F44E2A',
            'server' => 'keyserver.ubuntu.com'
          }
        },
        aptsource: {
          'openjdk-r' => {
            'comment'  => 'OpenJDK builds (all archs)',
            'location' => 'http://ppa.launchpad.net/openjdk-r/ppa/ubuntu',
            'repos'    => 'main',
            'release'  => 'trusty'
          }
        }
      }
    end

    it do
      should contain_apt__key('openjdk-r').with(
        id: 'DA1A4A13543B466853BAF164EB9B1D8886F44E2A',
        server: 'keyserver.ubuntu.com'
      )
      should contain_apt__source('openjdk-r').with(
        comment: 'OpenJDK builds (all archs)',
        location: 'http://ppa.launchpad.net/openjdk-r/ppa/ubuntu',
        repos: 'main',
        release: 'trusty'
      )
      should contain_exec('cassandra::java::apt_update')
    end
  end
end
