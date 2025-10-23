# frozen_string_literal: true

require 'spec_helper'

describe 'cassandra::schema::user' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'create a super user with login' do
        let(:title) { 'akers' }

        let(:params) do
          {
            password: 'Niner2',
            superuser: true
          }
        end

        read_command = "/usr/bin/cqlsh   -e \"LIST ROLES\" localhost 9042 | grep '\\s*akers |'"
        exec_command =  '/usr/bin/cqlsh   -e "CREATE ROLE IF NOT EXISTS akers '
        exec_command += "WITH PASSWORD = 'Niner2' AND SUPERUSER = true AND LOGIN = true\" localhost 9042"

        it do
          is_expected.to compile.with_all_deps
          is_expected.to contain_class('cassandra::schema')
          is_expected.to contain_exec('Create user (akers)').with(
            command: exec_command,
            unless: read_command,
            require: 'Exec[cassandra::schema connection test]'
          )
        end
      end

      context 'create a user without login' do
        let(:title) { 'bob' }

        let(:params) do
          {
            password: 'kaZe89a',
            login: false
          }
        end

        read_command = "/usr/bin/cqlsh   -e \"LIST ROLES\" localhost 9042 | grep '\\s*bob |'"
        exec_command =  '/usr/bin/cqlsh   -e "CREATE ROLE IF NOT EXISTS bob '
        exec_command += "WITH PASSWORD = 'kaZe89a'\" localhost 9042"

        it do
          is_expected.to compile.with_all_deps
          is_expected.to contain_exec('Create user (bob)').with(
            command: exec_command,
            unless: read_command,
            require: 'Exec[cassandra::schema connection test]'
          )
        end
      end

      context 'drop a user' do
        let(:title) { 'akers' }

        let(:params) do
          {
            ensure: 'absent'
          }
        end

        read_command = "/usr/bin/cqlsh   -e \"LIST ROLES\" localhost 9042 | grep '\\s*akers |'"
        exec_command = '/usr/bin/cqlsh   -e "DROP ROLE akers" localhost 9042'

        it do
          is_expected.to compile.with_all_deps
          is_expected.to contain_exec('Delete user (akers)').with(
            command: exec_command,
            onlyif: read_command,
            require: 'Exec[cassandra::schema connection test]'
          )
        end
      end

      context 'Set ensure to latest' do
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
