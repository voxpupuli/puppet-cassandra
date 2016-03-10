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
    should contain_exec('::cassandra::schema connection test')
      .only_with(command: '/usr/bin/cqlsh   -e \'DESC KEYSPACES;\'',
                 returns: 0,
                 tries: 6,
                 try_sleep: 30)
  end
end
