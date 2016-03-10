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

  let :facts do
    {
      osfamily: 'RedHat'
    }
  end

  context 'Test that a connection test is made.' do
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

  # context 'Test that a keyspace can be created.' do
  #  let :params do
  #    {
  #      cqlsh_host: 'localhost',
  #      cqlsh_port: 9042,
  #      keyspaces: [
  #        Excelsior: {
  #          ensure: 'present',
  #          durable_writes: false,
  #          replication_map: {
  #            keyspace_class: 'SimpleStrategy',
  #            replication_factor: 3
  #          }
  #        }
  #      ]
  #    }
  #  end
  # end
end
