# frozen_string_literal: true

require 'spec_helper'

describe 'cassandra' do
  describe 'service' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        it { is_expected.to compile.with_all_deps }

        context 'with default parameters' do
          it { is_expected.to contain_service('cassandra').with(ensure: 'running', enable: true) }
        end

        context 'with service_ensure is stopped' do
          let(:params) do
            {
              service_ensure: 'stopped'
            }
          end

          it { is_expected.to contain_service('cassandra').with(ensure: 'stopped', enable: true) }
        end

        context 'with manage_service is false' do
          let(:params) do
            {
              manage_service: false
            }
          end

          it { is_expected.not_to contain_service('cassandra') }
        end
      end
    end
  end
end
