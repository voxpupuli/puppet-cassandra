require 'spec_helper'
describe 'cassandra::dse' do
  let(:pre_condition) do
    [
      'class stdlib () {}',
      'define file_line($line, $path, $match) {}'
    ]
  end

  context 'with defaults for all parameters' do
    let :facts do
      {
        osfamily: 'RedHat',
        operatingsystemmajrelease: 7
      }
    end

    it do
      is_expected.to have_resource_count(6)
      is_expected.to contain_class('cassandra')

      is_expected.to contain_class('cassandra::dse').with(
        config_file_mode: '0644',
        config_file: '/etc/dse/dse.yaml'
      )
    end
  end
end
