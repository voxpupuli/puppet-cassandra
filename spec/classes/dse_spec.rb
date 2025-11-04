# frozen_string_literal: true

require 'spec_helper'
describe 'cassandra::dse' do
  context 'with defaults for all parameters' do
    let :facts do
      {
        os: {
          'family' => 'RedHat',
        }
      }
    end

    it do
      expect(subject).to have_resource_count(13)
      expect(subject).to contain_class('cassandra')

      expect(subject).to contain_class('cassandra::dse').with(
        config_file_mode: '0644',
        config_file: '/etc/dse/dse.yaml'
      )
    end
  end
end
