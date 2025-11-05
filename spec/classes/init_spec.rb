# frozen_string_literal: true

require 'spec_helper'

describe 'cassandra' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { is_expected.to compile.with_all_deps }

      context 'with default parameters' do
        it { is_expected.to contain_class('cassandra::install').that_comes_before('Class[cassandra::config]') }
        it { is_expected.to contain_class('cassandra::config').that_notifies('Class[cassandra::service]') }
        it { is_expected.to contain_class('cassandra::service') }
      end

      context 'with service_refresh => false' do
        let(:params) do
          {
            service_refresh: false
          }
        end

        it { is_expected.to contain_class('cassandra::install').that_comes_before('Class[cassandra::config]') }
        it { is_expected.to contain_class('cassandra::config').that_comes_before('Class[cassandra::service]') }
        it { is_expected.to contain_class('cassandra::service') }
      end
    end
  end
end
