# frozen_string_literal: true

require 'spec_helper'

describe 'cassandra::schema::table' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'create table with keyspace, columns and options' do
        let(:title) { 'users' }

        let(:params) do
          {
            keyspace: 'Excelsior',
            columns:
              {
                'userid' => 'text',
                'username' => 'FROZEN<fullname>',
                'emails' => 'set<text>',
                'top_scores' => 'list<int>',
                'todo' => 'map<timestamp, text>',
                'COLLECTION-TYPE' => 'tuple<int, text,text>',
                'PRIMARY KEY' => '(userid)'
              },
            options:
              [
                'COMPACT STORAGE',
                'ID=\'5a1c395e-b41f-11e5-9f22-ba0be0483c18\''
              ]
          }
        end

        read_command =  '/usr/bin/cqlsh   -e "DESC TABLE Excelsior.users" localhost 9042'
        exec_command =  '/usr/bin/cqlsh   -e "CREATE TABLE IF NOT EXISTS Excelsior.users '
        exec_command += '(userid text, username FROZEN<fullname>, emails set<text>, top_scores list<int>, '
        exec_command += 'todo map<timestamp, text>, tuple<int, text,text>, PRIMARY KEY (userid)) '
        exec_command += 'WITH COMPACT STORAGE AND ID=\'5a1c395e-b41f-11e5-9f22-ba0be0483c18\'" localhost 9042'

        it do
          is_expected.to compile.with_all_deps
          is_expected.to contain_class('cassandra::schema')
          is_expected.to contain_exec(exec_command).with(
            unless: read_command,
            require: 'Exec[cassandra::schema connection test]'
          )
        end
      end

      context 'drop table with keyspace' do
        let(:title) { 'users' }

        let(:params) do
          {
            keyspace: 'Excelsior',
            ensure: 'absent'
          }
        end

        read_command = '/usr/bin/cqlsh   -e "DESC TABLE Excelsior.users" localhost 9042'
        exec_command = '/usr/bin/cqlsh   -e "DROP TABLE IF EXISTS Excelsior.users" localhost 9042'

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
