require 'spec_helper'

describe 'cassandra::schema::user' do
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

  context 'Create a user' do
    let :facts do
      {
        operatingsystemmajrelease: 7,
        osfamily: 'RedHat'
      }
    end

    let(:title) { 'akers' }

    let(:params) do
      {
        password: 'Niner2',
        superuser: true
      }
    end

    it do
      should contain_cassandra__schema__user('akers').with_ensure('present')
      should contain_exec('Create user (akers)').with(
        command: '/usr/bin/cqlsh   -e "CREATE USER IF NOT EXISTS akers WITH PASSWORD \'Niner2\' SUPERUSER" localhost 9042'
      )
    end
  end

  context 'Drop a user' do
    let :facts do
      {
        operatingsystemmajrelease: 7,
        osfamily: 'RedHat'
      }
    end

    let(:title) { 'akers' }

    let(:params) do
      {
        password: 'Niner2',
        ensure: 'absent'
      }
    end

    it do
      should contain_exec('Delete user (akers)').with(
        command: '/usr/bin/cqlsh   -e "DROP USER akers" localhost 9042'
      )
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
