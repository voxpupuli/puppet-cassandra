require 'spec_helper'

describe 'cassandra::schema::index' do
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

  context 'Create a basic index' do
    let :facts do
      {
        osfamily: 'RedHat'
      }
    end

    let(:title) { 'user_index' }

    let(:params) do
      {
        keys: 'lname',
        keyspace: 'mykeyspace',
        table: 'users'
      }
    end

    it do
      should compile
      # rubocop:disable Metrics/LineLength
      should contain_exec('/usr/bin/cqlsh   -e "CREATE INDEX IF NOT EXISTS user_index ON mykeyspace.users (lname)"  ')
      # rubocop:enable Metrics/LineLength
    end
  end

  context 'Create a custom index.' do
    let :facts do
      {
        osfamily: 'RedHat'
      }
    end

    let(:title) { 'user_index' }

    let(:params) do
      {
        class_name: 'path.to.the.IndexClass',
        keys: 'email',
        keyspace: 'Excelsior',
        table: 'users'
      }
    end

    it do
      should compile
      # rubocop:disable Metrics/LineLength
      should contain_exec('/usr/bin/cqlsh   -e "CREATE CUSTOM INDEX IF NOT EXISTS user_index ON Excelsior.users (email) USING \'path.to.the.IndexClass\'"  ')
      # rubocop:enable Metrics/LineLength
    end
  end
  context 'Create a custom index with options.' do
    let :facts do
      {
        osfamily: 'RedHat'
      }
    end

    let(:title) { 'user_index' }

    let(:params) do
      {
        class_name: 'path.to.the.IndexClass',
        keys: 'email',
        keyspace: 'Excelsior',
        options: "{'storage': '/mnt/ssd/indexes/'}",
        table: 'users'
      }
    end

    it do
      should compile
      # rubocop:disable Metrics/LineLength
      should contain_exec('/usr/bin/cqlsh   -e "CREATE CUSTOM INDEX IF NOT EXISTS user_index ON Excelsior.users (email) USING \'path.to.the.IndexClass\' WITH OPTIONS = {\'storage\': \'/mnt/ssd/indexes/\'}"  ')
      # rubocop:enable Metrics/LineLength
    end
  end

  context 'Drop Index' do
    let :facts do
      {
        osfamily: 'RedHat'
      }
    end

    let(:title) { 'user_index' }

    let(:params) do
      {
        ensure: 'absent',
        keys: 'lname',
        keyspace: 'Excelsior',
        table: 'users'
      }
    end

    it do
      should compile
      # rubocop:disable Metrics/LineLength
      should contain_exec('/usr/bin/cqlsh   -e "DROP INDEX Excelsior.user_index"  ')
      # rubocop:enable Metrics/LineLength
    end
  end

  context 'Set ensure to latest' do
    let :facts do
      {
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
