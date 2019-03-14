require 'spec_helper'

describe 'cassandra::schema::keyspace' do
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
          },
        use_scl: false,
        scl_name: 'nodefault'
      }
    end

    it do
      is_expected.to compile
      is_expected.to contain_class('cassandra::schema')
      is_expected.to contain_exec('/usr/bin/cqlsh   -e "CREATE KEYSPACE IF NOT EXISTS foobar WITH REPLICATION = { \'class\' : \'SimpleStrategy\', \'replication_factor\' : 3 } AND DURABLE_WRITES = true" localhost 9042')
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
          },
        use_scl: false,
        scl_name: 'nodefault'
      }
    end

    it do
      is_expected.to contain_cassandra__schema__keyspace('foobar')
      is_expected.to contain_exec('/usr/bin/cqlsh   -e "CREATE KEYSPACE IF NOT EXISTS foobar WITH REPLICATION = { \'class\' : \'NetworkTopologyStrategy\', \'dc1\': 3, \'dc2\': 2 } AND DURABLE_WRITES = true" localhost 9042')
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
        ensure: 'absent',
        use_scl: false,
        scl_name: 'nodefault'
      }
    end

    it do
      is_expected.to compile
      is_expected.to contain_exec('/usr/bin/cqlsh   -e "DROP KEYSPACE foobar" localhost 9042')
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

    it { is_expected.to raise_error(Puppet::Error) }
  end
end
