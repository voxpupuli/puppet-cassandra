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

  let!(:stdlib_stubs) do
    MockFunction.new('strftime') do |f|
      f.stubbed.with('/var/lib/cassandra-%F')
       .returns('/var/lib/cassandra-YYYY-MM-DD')
    end
  end

  context 'On a Debian OS set the max and new heap size' do
    let :facts do
      {
        osfamily: 'Debian'
      }
    end

    let :params do
      {
        file: 'cassandra-env.sh',
        'file_lines' => {
          'MAX_HEAP_SIZE 4GB' => {
            'line'  => 'MAX_HEAP_SIZE="4G"',
            'match' => '^#MAX_HEAP_SIZE="4G"$'
          }
        }
      }
    end

    it do
      should contain_file_line('MAX_HEAP_SIZE 4GB').with(
        path: '/etc/cassandra/cassandra-env.sh',
        line: 'MAX_HEAP_SIZE="4G"',
        match: '^#MAX_HEAP_SIZE="4G"$'
      )
    end
  end
end
