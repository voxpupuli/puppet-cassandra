require 'spec_helper'
describe 'cassandra::optutils' do
  context 'On a RedHat OS with defaults for all parameters' do
    let :facts do
      {
        osfamily: 'RedHat'
      }
    end

    it { should have_resource_count(1) }
    it do
      should contain_class('cassandra::optutils').with(
        ensure: 'present',
        package_ensure: 'present'
      )
    end
    it { should contain_package('cassandra22-tools') }
  end

  context 'On a Debian OS with defaults for all parameters' do
    let :facts do
      {
        osfamily: 'Debian'
      }
    end

    it { should contain_class('cassandra::optutils') }
    it { should contain_package('cassandra-tools') }
  end

  context 'With package_name set to foobar' do
    let :params do
      {
        package_name: 'foobar-java',
        ensure: '42'
      }
    end

    it do
      should contain_package('foobar-java').with(
        ensure: 42
      )
    end
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
      should contain_package('cassandra22-tools').with_ensure('2.1.13-1')
      should contain_cassandra__private__deprecation_warning('cassandra::optutils::ensure')
    end
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

    it { should contain_package('cassandra-tools').with_ensure('2.1.13') }
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

    it { should contain_package('cassandra-tools').with_ensure('2.1.13') }
  end
end
