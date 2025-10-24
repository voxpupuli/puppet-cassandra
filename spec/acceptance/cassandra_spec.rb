# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'cassandra' do
  context 'with baseline_settings' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-PUPPET
        include java
        class { 'cassandra':
          baseline_settings => {
            authenticator               => 'AllowAllAuthenticator',
            authorizer                  => 'AllowAllAuthorizer',
            cluster_name                => 'MyCassandraCluster',
            commitlog_sync              => 'periodic',
            commitlog_sync_period_in_ms => 10000,
            listen_interface            => $facts['networking']['primary'],
            endpoint_snitch             => 'SimpleSnitch',
            partitioner                 => 'org.apache.cassandra.dht.Murmur3Partitioner',
            seed_provider               => [
              {
                class_name => 'org.apache.cassandra.locator.SimpleSeedProvider',
                parameters => [
                  {
                    seeds => $facts['networking']['ip']
                  },
                ],
              },
            ],
          },
        }
        Class['java'] -> Class['cassandra']
        PUPPET
      end
    end

    %w[cassandra cassandra-tools].each do |pkg|
      describe package(pkg) do
        it { is_expected.to be_installed }
      end
    end

    describe service('cassandra') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end
  end

  context 'with manage_service is false' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-PUPPET
        class { 'cassandra':
          service_ensure => 'stopped',
          service_enable => false,
        }
        PUPPET
      end
    end

    describe service('cassandra') do
      it { is_expected.not_to be_enabled }
      it { is_expected.not_to be_running }
    end
  end
end
