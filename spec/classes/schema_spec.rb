require 'spec_helper'
describe 'cassandra::schema' do
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

  let!(:stdlib_stubs) do
    MockFunction.new('strftime') do |f|
      f.stubbed.with('/var/lib/cassandra-%F')
       .returns('/var/lib/cassandra-YYYY-MM-DD')
    end
  end

  context 'Test that a connection test is made.' do
    let :facts do
      {
        osfamily: 'RedHat'
      }
    end

    let :params do
      {
        cqlsh_host: 'localhost',
        cqlsh_port: 9042
      }
    end

    it do
      should contain_class('cassandra::schema')
        .with(connection_tries: 6,
              connection_try_sleep: 30,
              cqlsh_additional_options: '',
              cqlsh_command: '/usr/bin/cqlsh',
              cqlsh_host: 'localhost',
              cqlsh_password: nil,
              cqlsh_port: 9042,
              cqlsh_user: 'cassandra',
              keyspaces: [])
    end

    it do
      read_command = '/usr/bin/cqlsh   -e \'DESC KEYSPACES\' localhost 9042'

      should contain_exec('::cassandra::schema connection test')
        .only_with(command: read_command,
                   returns: 0,
                   tries: 6,
                   try_sleep: 30,
                   unless: read_command)
    end
  end

  context 'Test that users can specify a credentials file.' do
    let :facts do
      {
        id: 'root',
        gid: 'root',
        osfamily: 'Debian'
      }
    end

    let :params do
      {
        cqlsh_client_config: '/root/.puppetcqlshrc'
      }
    end

    it do
      should contain_file('/root/.puppetcqlshrc').with(
        ensure: 'file',
        group: 'root',
        mode: '0600',
        owner: 'root',
        content: /username = cassandra/
      )

      read_command = "/usr/bin/cqlsh --cqlshrc=/root/.puppetcqlshrc  -e 'DESC KEYSPACES'  "

      should contain_exec('::cassandra::schema connection test')
        .only_with(command: read_command,
                   returns: 0,
                   tries: 6,
                   try_sleep: 30,
                   unless: read_command)
    end
  end

  context 'Test that users can specify a credentials file and password.' do
    let :facts do
      {
        id: 'root',
        gid: 'root',
        osfamily: 'Debian'
      }
    end

    let :params do
      {
        cqlsh_client_config: '/root/.puppetcqlshrc',
        cqlsh_password: 'topsecret'
      }
    end

    it do
      should contain_file('/root/.puppetcqlshrc').with(
        ensure: 'file',
        group: 'root',
        mode: '0600',
        owner: 'root',
        content: /password = topsecret/
      )

      read_command = "/usr/bin/cqlsh --cqlshrc=/root/.puppetcqlshrc  -e 'DESC KEYSPACES'  "

      should contain_exec('::cassandra::schema connection test')
        .only_with(command: read_command,
                   returns: 0,
                   tries: 6,
                   try_sleep: 30,
                   unless: read_command)
    end
  end

  context 'Test that users can specify a password.' do
    let :facts do
      {
        osfamily: 'Redhat'
      }
    end

    let :params do
      {
        cqlsh_password: 'topsecret'
      }
    end

    it do
      read_command = "/usr/bin/cqlsh -u cassandra -p topsecret  -e 'DESC KEYSPACES'  "

      should contain_exec('::cassandra::schema connection test')
        .only_with(command: read_command,
                   returns: 0,
                   tries: 6,
                   try_sleep: 30,
                   unless: read_command)
    end
  end
end
