require 'spec_helper'

describe 'cassandra::schema::keyspace' do
  let(:pre_condition) do
    [
      'define ini_setting($ensure = nil,
         $path,
         $section,
         $key_val_separator       = nil,
         $setting,
         $value                   = nil) {}'
    ]
  end

  context 'Set ensure to present (SimpleStrategy)' do
    let :facts do
      {
        operatingsystemmajrelease: 7,
        osfamily: 'RedHat'
      }
    end

    let(:title) { 'foobar' }

    let(:params) do
      {
        ensure: 'present',
        replication_map:
          {
            'keyspace_class'     => 'SimpleStrategy',
            'replication_factor' => 3
          }
      }
    end

    it do
      should compile
      should contain_class('cassandra::schema')
      should contain_exec('/usr/bin/cqlsh   -e "CREATE KEYSPACE IF NOT EXISTS foobar WITH REPLICATION = { \'class\' : \'SimpleStrategy\', \'replication_factor\' : 3 } AND DURABLE_WRITES = true" localhost 9042')
    end
  end

  context 'Set ensure to present (NetworkTopologyStrategy)' do
    let :facts do
      {
        operatingsystemmajrelease: 7,
        osfamily: 'RedHat'
      }
    end

    let(:title) { 'foobar' }

    let(:params) do
      {
        ensure: 'present',
        replication_map:
          {
            'keyspace_class' => 'NetworkTopologyStrategy',
            'dc1'            => '3',
            'dc2'            => '2'
          }
      }
    end

    it do
      should contain_cassandra__schema__keyspace('foobar')
      should contain_exec('/usr/bin/cqlsh   -e "CREATE KEYSPACE IF NOT EXISTS foobar WITH REPLICATION = { \'class\' : \'NetworkTopologyStrategy\', \'dc1\': 3, \'dc2\': 2 } AND DURABLE_WRITES = true" localhost 9042')
    end
  end

  context 'Set ensure to absent' do
    let :facts do
      {
        operatingsystemmajrelease: 7,
        osfamily: 'RedHat'
      }
    end

    let(:title) { 'foobar' }
    let(:params) do
      {
        ensure: 'absent'
      }
    end

    it do
      should compile
      should contain_exec('/usr/bin/cqlsh   -e "DROP KEYSPACE foobar" localhost 9042')
    end
  end

  context 'Set ensure to latest' do
    let :facts do
      {
        operatingsystemmajrelease: 7,
        osfamily: 'RedHat'
      }
    end

    let(:title) { 'foobar' }

    let(:params) do
      {
        ensure: 'latest'
      }
    end

    it { should raise_error(Puppet::Error) }
  end
end
