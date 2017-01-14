require 'spec_helper'

describe 'cassandra::system::disable_transparent_hugepage' do
  context 'Test the default parameters' do
    it do
      should have_resource_count(0)
      should contain_class('Cassandra::System::disable_transparent_hugepage')
    end
  end
end
