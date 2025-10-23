# frozen_string_literal: true

require 'spec_helper'

describe 'cassandra::schema::index' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'with a basic index' do
        let(:title) { 'user_index' }

        let(:params) do
          {
            keys: 'lname',
            keyspace: 'mykeyspace',
            table: 'users'
          }
        end

        read_command = '/usr/bin/cqlsh   -e "DESC INDEX mykeyspace.user_index" localhost 9042'
        exec_command = '/usr/bin/cqlsh   -e "CREATE INDEX IF NOT EXISTS user_index ON mykeyspace.users (lname)" localhost 9042'

        it do
          is_expected.to compile.with_all_deps
          is_expected.to contain_class('cassandra::schema')
          is_expected.to contain_exec(exec_command).with(
            unless: read_command,
            require: 'Exec[cassandra::schema connection test]'
          )
        end
      end

      context 'with a custom index' do
        let(:title) { 'user_index' }

        let(:params) do
          {
            class_name: 'path.to.the.IndexClass',
            keys: 'email',
            keyspace: 'Excelsior',
            table: 'users'
          }
        end

        read_command = '/usr/bin/cqlsh   -e "DESC INDEX Excelsior.user_index" localhost 9042'
        exec_command = '/usr/bin/cqlsh   -e "CREATE CUSTOM INDEX IF NOT EXISTS user_index ON Excelsior.users (email) USING \'path.to.the.IndexClass\'" localhost 9042'

        it do
          is_expected.to compile.with_all_deps
          is_expected.to contain_exec(exec_command).with(
            unless: read_command,
            require: 'Exec[cassandra::schema connection test]'
          )
        end
      end

      context 'with a custom index and options' do
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

        read_command = '/usr/bin/cqlsh   -e "DESC INDEX Excelsior.user_index" localhost 9042'
        exec_command =  '/usr/bin/cqlsh   -e "CREATE CUSTOM INDEX IF NOT EXISTS user_index '
        exec_command += "ON Excelsior.users (email) USING 'path.to.the.IndexClass' WITH OPTIONS = {'storage': '/mnt/ssd/indexes/'}\" localhost 9042"

        it do
          is_expected.to compile.with_all_deps
          is_expected.to contain_exec(exec_command).with(
            unless: read_command,
            require: 'Exec[cassandra::schema connection test]'
          )
        end
      end

      context 'with ensure absent' do
        let(:title) { 'user_index' }

        let(:params) do
          {
            ensure: 'absent',
            keys: 'lname',
            keyspace: 'Excelsior',
            table: 'users'
          }
        end

        read_command = '/usr/bin/cqlsh   -e "DESC INDEX Excelsior.user_index" localhost 9042'
        exec_command = '/usr/bin/cqlsh   -e "DROP INDEX Excelsior.user_index" localhost 9042'

        it do
          is_expected.to compile.with_all_deps
          is_expected.to contain_exec(exec_command).with(
            onlyif: read_command,
            require: 'Exec[cassandra::schema connection test]'
          )
        end
      end

      context 'with ensure latest' do
        let(:title) { 'foobar' }
        let(:params) do
          {
            ensure: 'latest'
          }
        end

        it { is_expected.to raise_error(Puppet::Error) }
      end
    end
  end
end
