# frozen_string_literal: true

require 'spec_helper'

describe 'cassandra::schema' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { is_expected.to compile.with_all_deps }

      context 'with default parameters' do
        read_command = "/usr/bin/cqlsh   -e 'DESC KEYSPACES' localhost 9042"

        it do
          is_expected.to contain_exec('cassandra::schema connection test').with(
            command: read_command,
            returns: 0,
            tries: 6,
            try_sleep: 30,
            unless: read_command
          )
        end
      end

      context 'with cqlsh_client_config file and identity = 0' do
        let(:facts) do
          super().merge('identity' => { 'uid' => 0, 'gid' => 0 })
        end

        let(:params) do
          {
            cqlsh_client_config: '/root/.puppetcqlshrc'
          }
        end

        read_command = "/usr/bin/cqlsh --cqlshrc=/root/.puppetcqlshrc  -e 'DESC KEYSPACES' localhost 9042"

        it do
          is_expected.to contain_file('/root/.puppetcqlshrc').with(
            ensure: 'file',
            group: 0,
            mode: '0600',
            owner: 0,
            content: %r{username = cassandra}
          ).that_comes_before('Exec[cassandra::schema connection test]')

          is_expected.to contain_exec('cassandra::schema connection test').with(
            command: read_command,
            returns: 0,
            tries: 6,
            try_sleep: 30,
            unless: read_command
          )
        end
      end

      context 'with cqlsh_client_config file and password' do
        let(:params) do
          {
            cqlsh_client_config: '/root/.puppetcqlshrc',
            cqlsh_password: 'topsecret'
          }
        end

        read_command = "/usr/bin/cqlsh --cqlshrc=/root/.puppetcqlshrc  -e 'DESC KEYSPACES' localhost 9042"

        it do
          is_expected.to contain_file('/root/.puppetcqlshrc').with(
            ensure: 'file',
            mode: '0600',
            content: %r{password = topsecret}
          )

          is_expected.to contain_exec('cassandra::schema connection test').with(
            command: read_command,
            returns: 0,
            tries: 6,
            try_sleep: 30,
            unless: read_command
          )
        end
      end

      context 'with password and without cqlsh_client_config' do
        let(:params) do
          {
            cqlsh_password: 'topsecret'
          }
        end

        read_command = "/usr/bin/cqlsh -u cassandra -p topsecret  -e 'DESC KEYSPACES' localhost 9042"

        it do
          is_expected.to contain_exec('cassandra::schema connection test').with(
            command: read_command,
            returns: 0,
            tries: 6,
            try_sleep: 30,
            unless: read_command
          )
        end
      end
    end
  end
end
