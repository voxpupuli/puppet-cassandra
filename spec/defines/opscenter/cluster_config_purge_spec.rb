require 'spec_helper'
describe 'cassandra::opscenter::cluster_name' do
  let(:pre_condition) do
    [
      'class cassandra::opscenter ($config_purge = true) {}',
      'define ini_setting($ensure = nil,
         $path,
         $section,
         $key_val_separator       = nil,
         $setting,
         $value                   = nil) {}'
    ]
  end
  context 'Test that non-puppet clusters can be purged.' do
    let(:title) { 'MyCluster' }

    let :params do
      {
        cassandra_seed_hosts: 'host1,host2',
        storage_cassandra_keyspace: 'MyCluster_opc_keyspace',
        storage_cassandra_seed_hosts: 'host1,host2'
      }
    end

    it do
      should contain_file('/etc/opscenter/clusters')
        .with('ensure' => 'directory',
              'purge'   => true,
              'recurse' => true)
    end
  end
end
