require 'spec_helper'
describe 'cassandra::optutils' do
  context 'On a RedHat OS with defaults for all parameters' do
    let :facts do
      {
        osfamily: 'RedHat'
      }
    end

    it do
      should have_resource_count(1)
      should contain_package('cassandra22-tools').with(ensure: 'present')

      should contain_class('cassandra::optutils').with(
        package_ensure: 'present',
        package_name: 'cassandra22-tools'
      )
    end
  end

  context 'On a Debian OS with defaults for all parameters' do
    let :facts do
      {
        osfamily: 'Debian'
      }
    end

    it do
      should contain_package('cassandra-tools').with(ensure: 'present')

      should contain_class('cassandra::optutils').with(
        package_ensure: 'present',
        package_name: 'cassandra-tools'
      )
    end
  end

  context 'With package_name set to foobar' do
    let :params do
      {
        package_name: 'foobar-java',
        package_ensure: '42'
      }
    end

    it do
      should contain_package('foobar-java').with(ensure: 42)
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
end
