# frozen_string_literal: true

require 'spec_helper'

describe 'cassandra::schema::permission' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'with user_name and default parameters' do
        let(:title) { 'foobar' }
        let(:params) do
          {
            user_name: 'foobar'
          }
        end

        it { is_expected.to raise_error(Puppet::Error) }
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

      context 'with spillman user_name and SELECT permission' do
        let(:title) { 'spillman:SELECT' }

        let(:params) do
          {
            user_name: 'spillman',
            permission_name: 'SELECT'
          }
        end

        read_script =  '/usr/bin/cqlsh   -e "LIST ALL PERMISSIONS ON ALL KEYSPACES" '
        read_script += "localhost 9042 | grep ' spillman | *spillman | .* SELECT$'"
        script_command = 'GRANT SELECT ON ALL KEYSPACES TO spillman'
        exec_command = "/usr/bin/cqlsh   -e \"#{script_command}\" localhost 9042"

        it do
          is_expected.to compile.with_all_deps
          is_expected.to contain_class('cassandra::schema')
          is_expected.to contain_exec(script_command).with(
            command: exec_command,
            unless: read_script,
            require: 'Exec[cassandra::schema connection test]'
          )
        end
      end

      context 'with user_name => akers, keyspace_name => field and permission_name => MODIFY' do
        let(:title) { 'akers:modify:field' }

        let(:params) do
          {
            user_name: 'akers',
            keyspace_name: 'field',
            permission_name: 'MODIFY'
          }
        end

        read_script =  '/usr/bin/cqlsh   -e "LIST ALL PERMISSIONS ON KEYSPACE field" '
        read_script += 'localhost 9042 | grep \' akers | *akers | .* MODIFY$\''
        script_command = 'GRANT MODIFY ON KEYSPACE field TO akers'
        exec_command = "/usr/bin/cqlsh   -e \"#{script_command}\" localhost 9042"

        it do
          is_expected.to compile.with_all_deps
          is_expected.to contain_exec(script_command).with(
            command: exec_command,
            unless: read_script,
            require: 'Exec[cassandra::schema connection test]'
          )
        end
      end

      context 'with user_name => boone, keyspace_name => forty9ers and permission_name => ALTER' do
        let(:title) { 'boone:alter:forty9ers' }

        let(:params) do
          {
            user_name: 'boone',
            keyspace_name: 'forty9ers',
            permission_name: 'ALTER'
          }
        end

        read_script =  '/usr/bin/cqlsh   -e "LIST ALL PERMISSIONS ON KEYSPACE forty9ers" '
        read_script += 'localhost 9042 | grep \' boone | *boone | .* ALTER$\''
        script_command = 'GRANT ALTER ON KEYSPACE forty9ers TO boone'
        exec_command = "/usr/bin/cqlsh   -e \"#{script_command}\" localhost 9042"

        it do
          is_expected.to compile.with_all_deps
          is_expected.to contain_exec(script_command).with(
            command: exec_command,
            unless: read_script,
            require: 'Exec[cassandra::schema connection test]'
          )
        end
      end

      context 'with user_name => boone, keyspace_name => ravens and table_name => plays' do
        let(:title) { 'boone:ALL:ravens.plays' }

        let(:params) do
          {
            user_name: 'boone',
            keyspace_name: 'ravens',
            table_name: 'plays'
          }
        end

        expected_values = %w[ALTER AUTHORIZE DROP MODIFY SELECT]
        expected_values.each do |val|
          read_script =  '/usr/bin/cqlsh   -e "LIST ALL PERMISSIONS ON TABLE ravens.plays" '
          read_script += "localhost 9042 | grep ' boone | *boone | .* #{val}$'"
          script_command = "GRANT #{val} ON TABLE ravens.plays TO boone"
          exec_command = "/usr/bin/cqlsh   -e \"#{script_command}\" localhost 9042"

          it do
            is_expected.to compile.with_all_deps
            is_expected.to contain_cassandra__schema__permission("boone:ALL:ravens.plays - #{val}").with(
              ensure: 'present',
              user_name: 'boone',
              keyspace_name: 'ravens',
              permission_name: val,
              table_name: 'plays'
            )
            is_expected.to contain_exec(script_command).with(
              command: exec_command,
              unless: read_script,
              require: 'Exec[cassandra::schema connection test]'
            )
          end
        end
      end

      context 'with ensure => absent, user_name => boone, keyspace_name => forty9ers and permission_name => SELECT' do
        let(:title) { 'REVOKE boone:SELECT:ravens.plays' }

        let(:params) do
          {
            ensure: 'absent',
            user_name: 'boone',
            keyspace_name: 'forty9ers',
            permission_name: 'SELECT'
          }
        end

        read_script =  '/usr/bin/cqlsh   -e "LIST ALL PERMISSIONS ON KEYSPACE forty9ers" '
        read_script += "localhost 9042 | grep ' boone | *boone | .* SELECT$'"
        script_command = 'REVOKE SELECT ON KEYSPACE forty9ers FROM boone'
        exec_command = "/usr/bin/cqlsh   -e \"#{script_command}\" localhost 9042"

        it do
          is_expected.to compile.with_all_deps
          is_expected.to contain_exec(script_command).with(
            command: exec_command,
            onlyif: read_script,
            require: 'Exec[cassandra::schema connection test]'
          )
        end
      end
    end
  end
end
