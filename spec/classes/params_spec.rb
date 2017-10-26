require 'spec_helper'

describe '::cassandra::params' do
  let :facts do
    {
      osfamily: 'RedHat',
      operatingsystemmajrelease: '7'
    }
  end

  it do
    is_expected.to compile
    is_expected.to contain_class('cassandra::params')
    is_expected.to have_resource_count(0)
  end
end
