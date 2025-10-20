# frozen_string_literal: true

require 'spec_helper'

describe 'cassandra::schema::user' do
  let :node do
    'foo.example.com'
  end

  on_supported_os.each do |_os, facts|
    let :facts do
      facts
    end

    context 'Create a super user with login' do
      let(:title) { 'akers' }

      let(:params) do
        {
          password: 'Niner2',
          superuser: true
        }
      end

      it do
        expect(subject).to contain_cassandra__schema__user('akers').with_ensure('present')
        read_command = '/usr/bin/cqlsh   -e "LIST ROLES" localhost 9042 | grep \'\s*akers |\''
        exec_command =  '/usr/bin/cqlsh   -e "CREATE ROLE IF NOT EXISTS akers'
        exec_command += ' WITH PASSWORD = \'Niner2\' AND SUPERUSER = true AND LOGIN = true" localhost 9042'
        expect(subject).to contain_exec('Create user (akers)').
          only_with(command: exec_command,
                    unless: read_command,
                    require: 'Exec[cassandra::schema connection test]')
      end
    end

    context 'Create a user without login' do
      let(:title) { 'bob' }

      let(:params) do
        {
          password: 'kaZe89a',
          login: false
        }
      end

      it do
        expect(subject).to contain_cassandra__schema__user('bob').with_ensure('present')
        read_command = '/usr/bin/cqlsh   -e "LIST ROLES" localhost 9042 | grep \'\s*bob |\''
        exec_command =  '/usr/bin/cqlsh   -e "CREATE ROLE IF NOT EXISTS bob'
        exec_command += ' WITH PASSWORD = \'kaZe89a\'" localhost 9042'
        expect(subject).to contain_exec('Create user (bob)').
          only_with(command: exec_command,
                    unless: read_command,
                    require: 'Exec[cassandra::schema connection test]')
      end
    end

    context 'Drop a user' do
      let(:title) { 'akers' }

      let(:params) do
        {
          password: 'Niner2',
          ensure: 'absent'
        }
      end

      it do
        read_command = '/usr/bin/cqlsh   -e "LIST ROLES" localhost 9042 | grep \'\s*akers |\''
        exec_command = '/usr/bin/cqlsh   -e "DROP ROLE akers" localhost 9042'
        expect(subject).to contain_exec('Delete user (akers)').
          only_with(command: exec_command,
                    onlyif: read_command,
                    require: 'Exec[cassandra::schema connection test]')
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
