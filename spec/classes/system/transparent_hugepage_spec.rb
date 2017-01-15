require 'spec_helper'

describe 'cassandra::system::transparent_hugepage' do
  context 'Test the default parameters (RedHat)' do
    let :facts do
      {
        osfamily: 'RedHat'
      }
    end

    it do
      should have_resource_count(1)
      should contain_class('cassandra::system::transparent_hugepage')
      should contain_exec('Disable Java Hugepages')
    end
  end

  context 'Test the default parameters (Debian)' do
    let :facts do
      {
        osfamily: 'Debian'
      }
    end

    it do
      should have_resource_count(1)
      should contain_class('cassandra::system::transparent_hugepage')
      should contain_exec('Disable Java Hugepages')
    end
  end
end
