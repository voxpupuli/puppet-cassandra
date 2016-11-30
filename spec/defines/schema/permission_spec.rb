require 'spec_helper'

describe 'cassandra::schema::permission' do
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

    it { should raise_error(Puppet::Error) }
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
      should have_resource_count(9)
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
      should have_resource_count(9)
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
      should have_resource_count(9)
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
      should have_resource_count(18)
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
      should have_resource_count(9)
    end
  end
end
