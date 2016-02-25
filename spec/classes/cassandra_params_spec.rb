require 'spec_helper'

describe '::cassandra::params' do
  it { should compile }
  it { should contain_class('cassandra::params') }
  it { should have_resource_count(0) }
end
