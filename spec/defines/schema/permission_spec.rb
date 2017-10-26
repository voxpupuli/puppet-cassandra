require 'spec_helper'

describe 'cassandra::schema::permission' do
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
        user_name: 'foobar'
      }
    end

    it { is_expected.to raise_error(Puppet::Error) }
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

  context 'spillman:SELECT:ALL' do
    let(:title) { 'spillman:SELECT:ALL' }
    let :facts do
      {
        operatingsystemmajrelease: 7,
        osfamily: 'RedHat'
      }
    end

    let(:params) do
      {
        user_name: 'spillman',
        permission_name: 'SELECT'
      }
    end

    it do
      is_expected.to have_resource_count(9)
      is_expected.to contain_cassandra__schema__permission('spillman:SELECT:ALL')
      is_expected.to contain_exec('GRANT SELECT ON ALL KEYSPACES TO spillman')
    end
  end

  context 'akers:modify:field' do
    let(:title) { 'akers:modify:field' }
    let :facts do
      {
        operatingsystemmajrelease: 7,
        osfamily: 'RedHat'
      }
    end

    let(:params) do
      {
        user_name: 'akers',
        keyspace_name: 'field',
        permission_name: 'MODIFY'
      }
    end

    it do
      is_expected.to have_resource_count(9)
      is_expected.to contain_cassandra__schema__permission('akers:modify:field')
      is_expected.to contain_exec('GRANT MODIFY ON KEYSPACE field TO akers')
    end
  end

  context 'boone:alter:forty9ers' do
    let(:title) { 'boone:alter:forty9ers' }
    let :facts do
      {
        operatingsystemmajrelease: 7,
        osfamily: 'RedHat'
      }
    end

    let(:params) do
      {
        user_name: 'boone',
        keyspace_name: 'forty9ers',
        permission_name: 'ALTER'
      }
    end

    it do
      is_expected.to have_resource_count(9)
      is_expected.to contain_cassandra__schema__permission('boone:alter:forty9ers')
      is_expected.to contain_exec('GRANT ALTER ON KEYSPACE forty9ers TO boone')
    end
  end

  context 'boone:ALL:ravens.plays' do
    let(:title) { 'boone:ALL:ravens.plays' }
    let :facts do
      {
        operatingsystemmajrelease: 7,
        osfamily: 'RedHat'
      }
    end

    let(:params) do
      {
        user_name: 'boone',
        keyspace_name: 'ravens',
        table_name: 'plays'
      }
    end

    it do
      is_expected.to have_resource_count(18)
      is_expected.to contain_cassandra__schema__permission('boone:ALL:ravens.plays')
      is_expected.to contain_cassandra__schema__permission('boone:ALL:ravens.plays - ALTER').with(
        ensure: 'present',
        user_name: 'boone',
        keyspace_name: 'ravens',
        permission_name: 'ALTER',
        table_name: 'plays'
      )
      is_expected.to contain_cassandra__schema__permission('boone:ALL:ravens.plays - AUTHORIZE')
      is_expected.to contain_cassandra__schema__permission('boone:ALL:ravens.plays - DROP')
      is_expected.to contain_cassandra__schema__permission('boone:ALL:ravens.plays - MODIFY')
      is_expected.to contain_cassandra__schema__permission('boone:ALL:ravens.plays - SELECT')
      is_expected.to contain_exec('GRANT ALTER ON TABLE ravens.plays TO boone')
      is_expected.to contain_exec('GRANT AUTHORIZE ON TABLE ravens.plays TO boone')
      is_expected.to contain_exec('GRANT DROP ON TABLE ravens.plays TO boone')
      is_expected.to contain_exec('GRANT MODIFY ON TABLE ravens.plays TO boone')
      is_expected.to contain_exec('GRANT SELECT ON TABLE ravens.plays TO boone')
    end
  end

  context 'REVOKE boone:SELECT:ravens.plays' do
    let(:title) { 'REVOKE boone:SELECT:ravens.plays' }
    let :facts do
      {
        operatingsystemmajrelease: 7,
        osfamily: 'RedHat'
      }
    end

    let(:params) do
      {
        ensure: 'absent',
        user_name: 'boone',
        keyspace_name: 'forty9ers',
        permission_name: 'SELECT'
      }
    end

    it do
      is_expected.to have_resource_count(9)
      is_expected.to contain_cassandra__schema__permission('REVOKE boone:SELECT:ravens.plays')
      is_expected.to contain_exec('REVOKE SELECT ON KEYSPACE forty9ers FROM boone')
    end
  end
end
