require 'spec_helper'

describe '::cassandra::params' do
  let :facts do
    {
      osfamily: 'RedHat',
      operatingsystemmajrelease: 7
    }
  end

  it do
    should compile
    should contain_class('cassandra::params')
    should have_resource_count(0)
  end
end
