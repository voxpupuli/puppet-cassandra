require 'spec_helper'

describe '::cassandra::file' do
  let(:pre_condition) do
    [
      'class stdlib () {}',
      'define ini_setting($ensure = nil,
         $path,
         $section,
         $key_val_separator       = nil,
         $setting,
         $value                   = nil) {}',
      'define file_line($line, $path, $match) {}'
    ]
  end

  context 'On a Debian OS set the max and new heap size' do
    let :facts do
      {
        osfamily: 'Debian',
        operatingsystemmajrelease: 8
      }
    end

    let(:title) { 'cassandra-env.sh' }

    let :params do
      {
        config_path: '/etc/cassandra',
        'file_lines' => {
          'MAX_HEAP_SIZE 4GB' => {
            'line'  => 'MAX_HEAP_SIZE="4G"',
            'match' => '^#MAX_HEAP_SIZE="4G"$'
          }
        }
      }
    end

    it do
      is_expected.to contain_class('cassandra')
      is_expected.to contain_class('cassandra::params')
      is_expected.to contain_class('stdlib')
      is_expected.to contain_cassandra__file('cassandra-env.sh')

      is_expected.to contain_file_line('MAX_HEAP_SIZE 4GB').with(
        path: '/etc/cassandra/cassandra-env.sh',
        line: 'MAX_HEAP_SIZE="4G"',
        match: '^#MAX_HEAP_SIZE="4G"$'
      )
    end
  end
end
