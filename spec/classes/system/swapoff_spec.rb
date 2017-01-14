require 'spec_helper'

describe 'cassandra::system::swapoff' do
  context 'Test the default parameters' do
    it do
      should have_resource_count(0)
      should contain_class('Cassandra::System::Swapoff')
    end
  end
end
