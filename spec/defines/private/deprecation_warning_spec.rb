require 'spec_helper'

describe '::cassandra::private::deprecation_warning' do
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
    MockFunction.new('concat') do |f|
      f.stubbed.with([], '/etc/cassandra')
       .returns(['/etc/cassandra'])
      f.stubbed.with([], '/etc/cassandra/default.conf')
       .returns(['/etc/cassandra/default.conf'])
      f.stubbed.with(['/etc/cassandra'], '/etc/cassandra/default.conf')
       .returns(['/etc/cassandra', '/etc/cassandra/default.conf'])
    end
    MockFunction.new('strftime') do |f|
      f.stubbed.with('/var/lib/cassandra-%F')
       .returns('/var/lib/cassandra-YYYY-MM-DD')
    end
  end

  context 'Test ::cassandra::private::deprecation_warning' do
    let :facts do
      {
        osfamily: 'Debian'
      }
    end

    let(:title) { 'Deprecated feature' }

    let :params do
      {
        item_number: 42
      }
    end

    it do
      should compile
      should contain_cassandra__private__deprecation_warning('Deprecated feature').with(
        item_number: 42
      )
    end
  end
end
