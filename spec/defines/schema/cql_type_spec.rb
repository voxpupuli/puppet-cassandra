# frozen_string_literal: true

require 'spec_helper'

describe 'cassandra::schema::cql_type' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'with CQL TYPE (fullname)' do
        let(:title) { 'fullname' }

        let(:params) do
          {
            'keyspace' => 'Excelsior',
            'fields'   => {
              'firstname' => 'text',
              'lastname' => 'text'
            },
          }
        end

        read_command = '/usr/bin/cqlsh   -e "DESC TYPE Excelsior.fullname" localhost 9042'
        exec_command = '/usr/bin/cqlsh   -e "CREATE TYPE IF NOT EXISTS Excelsior.fullname (firstname text, lastname text)" localhost 9042'

        it do
          is_expected.to compile.with_all_deps
          is_expected.to contain_class('cassandra::schema')
          is_expected.to contain_exec(exec_command).with(
            unless: read_command,
            require: 'Exec[cassandra::schema connection test]'
          )
        end
      end

      context 'with ensure absent' do
        let(:title) { 'address' }
        let(:params) do
          {
            'ensure' => 'absent',
            'keyspace' => 'Excalibur'
          }
        end

        read_command = '/usr/bin/cqlsh   -e "DESC TYPE Excalibur.address" localhost 9042'
        exec_command = '/usr/bin/cqlsh   -e "DROP type Excalibur.address" localhost 9042'

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
