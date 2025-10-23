# frozen_string_literal: true

require 'spec_helper'

describe 'cassandra::schema::keyspace' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'with keyspace_class => SimpleStrategy' do
        let(:title) { 'foobar' }

        let(:params) do
          {
            ensure: 'present',
            replication_map:
              {
                'keyspace_class' => 'SimpleStrategy',
                'replication_factor' => 3
              },
          }
        end

        read_command =  '/usr/bin/cqlsh   -e "DESC KEYSPACE foobar" localhost 9042'
        exec_command =  '/usr/bin/cqlsh   -e "CREATE KEYSPACE IF NOT EXISTS foobar WITH REPLICATION = '
        exec_command += "{ 'class' : 'SimpleStrategy', 'replication_factor' : 3 } AND DURABLE_WRITES = true\" localhost 9042"

        it do
          is_expected.to compile.with_all_deps
          is_expected.to contain_class('cassandra::schema')
          is_expected.to contain_exec(exec_command).with(
            unless: read_command,
            require: 'Exec[cassandra::schema connection test]'
          )
        end
      end

      context 'with keyspace_class => NetworkTopologyStrategy' do
        let(:title) { 'foobar' }

        let(:params) do
          {
            ensure: 'present',
            replication_map:
              {
                'keyspace_class' => 'NetworkTopologyStrategy',
                'dc1' => '3',
                'dc2' => '2'
              },
          }
        end

        read_command =  '/usr/bin/cqlsh   -e "DESC KEYSPACE foobar" localhost 9042'
        exec_command =  '/usr/bin/cqlsh   -e "CREATE KEYSPACE IF NOT EXISTS foobar WITH REPLICATION = '
        exec_command += "{ 'class' : 'NetworkTopologyStrategy', 'dc1': 3, 'dc2': 2 } AND DURABLE_WRITES = true\" localhost 9042"

        it do
          is_expected.to compile.with_all_deps
          is_expected.to contain_exec(exec_command).with(
            unless: read_command,
            require: 'Exec[cassandra::schema connection test]'
          )
        end
      end

      context 'Set ensure to absent' do
        let(:title) { 'foobar' }
        let(:params) do
          {
            ensure: 'absent'
          }
        end

        read_command = '/usr/bin/cqlsh   -e "DESC KEYSPACE foobar" localhost 9042'
        exec_command = '/usr/bin/cqlsh   -e "DROP KEYSPACE foobar" localhost 9042'
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
