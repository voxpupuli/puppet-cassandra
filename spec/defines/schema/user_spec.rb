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

  context 'Create a supper user on cassandrarelease undef' do
    let :facts do
      {
        operatingsystemmajrelease: 7,
        osfamily: 'RedHat',
        cassandrarelease: nil
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

  context 'Create a supper user in cassandrarelease < 2.2' do
    let :facts do
      {
        operatingsystemmajrelease: 7,
        osfamily: 'RedHat',
        cassandrarelease: '2.0.1'
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

  context 'Create a user in cassandrarelease < 2.2' do
    let :facts do
      {
        operatingsystemmajrelease: 7,
        osfamily: 'RedHat',
        cassandrarelease: '2.0.1'
      }
    end

    let(:title) { 'akers' }

    let(:params) do
      {
        password: 'Niner2'
      }
    end

    it do
      should contain_cassandra__schema__user('akers').with_ensure('present')
      should contain_exec('Create user (akers)').with(
        command: '/usr/bin/cqlsh   -e "CREATE USER IF NOT EXISTS akers WITH PASSWORD \'Niner2\' NOSUPERUSER" localhost 9042'
      )
    end
  end

  context 'Create a supper user with login in cassandrarelease > 2.2' do
    let :facts do
      {
        operatingsystemmajrelease: 7,
        osfamily: 'RedHat',
        cassandrarelease: '3.0.9'
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
        command: '/usr/bin/cqlsh   -e "CREATE ROLE IF NOT EXISTS akers WITH PASSWORD = \'Niner2\' AND SUPERUSER = true AND LOGIN = true" localhost 9042'
      )
    end
  end

  context 'Create a user without login in cassandrarelease > 2.2' do
    let :facts do
      {
        operatingsystemmajrelease: 7,
        osfamily: 'RedHat',
        cassandrarelease: '3.0.9'
      }
    end

    let(:title) { 'bob' }

    let(:params) do
      {
        password: 'kaZe89a',
        login: false
      }
    end

    it do
      should contain_cassandra__schema__user('bob').with_ensure('present')
      should contain_exec('Create user (bob)').with(
        command: '/usr/bin/cqlsh   -e "CREATE ROLE IF NOT EXISTS bob WITH PASSWORD = \'kaZe89a\'" localhost 9042'
      )
    end
  end

  context 'Drop a user in cassandrarelease > 2.2' do
    let :facts do
      {
        operatingsystemmajrelease: 7,
        osfamily: 'RedHat',
        cassandrarelease: '3.0.9'
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
        command: '/usr/bin/cqlsh   -e "DROP ROLE akers" localhost 9042'
      )
    end
  end

  context 'Drop a user in cassandrarelease < 2.2' do
    let :facts do
      {
        operatingsystemmajrelease: 7,
        osfamily: 'RedHat',
        cassandrarelease: '2.0.2'
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
