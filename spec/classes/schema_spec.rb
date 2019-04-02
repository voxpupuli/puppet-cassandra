require 'spec_helper'
describe 'cassandra::schema' do
  context 'Ensure that a connection test is made.' do
    let :facts do
      {
        operatingsystemmajrelease: 7,
        osfamily: 'RedHat'
      }
    end

    it do
      is_expected.to contain_class('cassandra::schema').
        with(connection_tries: 6,
             connection_try_sleep: 30,
             cqlsh_additional_options: '',
             cqlsh_command: '/usr/bin/cqlsh',
             cqlsh_host: 'localhost',
             cqlsh_password: nil,
             cqlsh_port: 9042,
             cqlsh_user: 'cassandra')

      read_command = '/usr/bin/cqlsh   -e \'DESC KEYSPACES\' localhost 9042'

      is_expected.to contain_exec('::cassandra::schema connection test').
        only_with(command: read_command,
                  returns: 0,
                  tries: 6,
                  try_sleep: 30,
                  unless: read_command)
    end
  end

  context 'Ensure that a connection test is made with SCL.' do
    let :facts do
      {
        operatingsystemmajrelease: 7,
        osfamily: 'RedHat'
      }
    end

    let :params do
      {
        use_scl: true,
        scl_name: 'testscl'
      }
    end

    it do
      is_expected.to contain_class('cassandra::schema').
        with(connection_tries: 6,
             connection_try_sleep: 30,
             cqlsh_additional_options: '',
             cqlsh_command: '/usr/bin/cqlsh',
             cqlsh_host: 'localhost',
             cqlsh_password: nil,
             cqlsh_port: 9042,
             cqlsh_user: 'cassandra')

      read_command = '/usr/bin/scl enable testscl "/usr/bin/cqlsh   -e \'DESC KEYSPACES\' localhost 9042"'

      is_expected.to contain_exec('::cassandra::schema connection test').
        only_with(command: read_command,
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
        operatingsystemmajrelease: 7,
        osfamily: 'Debian'
      }
    end

    let :params do
      {
        cqlsh_client_config: '/root/.puppetcqlshrc',
        use_scl: false,
        scl_name: 'nodefault'
      }
    end

    it do
      is_expected.to contain_file('/root/.puppetcqlshrc').with(
        ensure: 'file',
        group: 'root',
        mode: '0600',
        owner: 'root',
        content: %r{username = cassandra}
      ).that_comes_before('Exec[::cassandra::schema connection test]')

      read_command = "/usr/bin/cqlsh --cqlshrc=/root/.puppetcqlshrc  -e 'DESC KEYSPACES' localhost 9042"

      is_expected.to contain_exec('::cassandra::schema connection test').
        only_with(command: read_command,
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
        operatingsystemmajrelease: 7,
        osfamily: 'Debian'
      }
    end

    let :params do
      {
        cqlsh_client_config: '/root/.puppetcqlshrc',
        cqlsh_password: 'topsecret',
        use_scl: false,
        scl_name: 'nodefault'
      }
    end

    it do
      is_expected.to contain_file('/root/.puppetcqlshrc').with(
        ensure: 'file',
        group: 'root',
        mode: '0600',
        owner: 'root',
        content: %r{password = topsecret}
      )

      read_command = "/usr/bin/cqlsh --cqlshrc=/root/.puppetcqlshrc  -e 'DESC KEYSPACES' localhost 9042"

      is_expected.to contain_exec('::cassandra::schema connection test').
        only_with(command: read_command,
                  returns: 0,
                  tries: 6,
                  try_sleep: 30,
                  unless: read_command)
    end
  end

  context 'Test that users can specify a password.' do
    let :facts do
      {
        operatingsystemmajrelease: 7,
        osfamily: 'Redhat'
      }
    end

    let :params do
      {
        cqlsh_password: 'topsecret'
      }
    end

    it do
      read_command = "/usr/bin/cqlsh -u cassandra -p topsecret  -e 'DESC KEYSPACES' localhost 9042"

      is_expected.to contain_exec('::cassandra::schema connection test').
        only_with(command: read_command,
                  returns: 0,
                  tries: 6,
                  try_sleep: 30,
                  unless: read_command)
    end
  end
end
