# frozen_string_literal: true

require 'spec_helper'

describe 'cassandra' do
  describe 'install' do
    context 'on an unsupported OS with default parameters' do
      let(:facts) do
        {
          os: {
            family: 'Unknown',
            release: { full: '1.0' }
          }
        }
      end

      it { is_expected.to raise_error(Puppet::Error) }
    end

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        it { is_expected.to compile.with_all_deps }

        context 'with default parameters' do
          it { is_expected.not_to contain_group('cassandra') }
          it { is_expected.not_to contain_user('cassandra') }

          case facts[:os]['family']
          when 'RedHat'
            it do
              is_expected.to contain_yumrepo('cassandra').with(
                baseurl: 'https://redhat.cassandra.apache.org/50x',
                repo_gpgcheck: 1,
                gpgcheck: 0,
                enabled: 1,
                gpgkey: 'https://downloads.apache.org/cassandra/KEYS'
              ).that_comes_before('Package[cassandra]')
            end
          when 'Debian'
            it do
              is_expected.to contain_apt__source('cassandra').with(
                location: 'https://debian.cassandra.apache.org',
                release: '50x',
                repos: 'main',
                key: {
                  'name' => 'apache-cassandra.asc',
                  'source' => 'https://downloads.apache.org/cassandra/KEYS'
                }
              ).that_comes_before('Package[cassandra]')
            end

            it { is_expected.to contain_class('apt::update').that_comes_before('Package[cassandra]') }
          end

          it { is_expected.to contain_package('cassandra').with_ensure('installed') }
          it { is_expected.to contain_package('cassandra-tools').with_ensure('installed') }
        end

        context 'with different user and group' do
          let(:params) do
            {
              manage_user: true,
              user: 'A1234',
              group: 'A1234'
            }
          end

          it { is_expected.to contain_group('A1234').with(ensure: 'present') }
          it { is_expected.to contain_user('A1234').with(ensure: 'present') }
        end

        context 'with different uid and gid' do
          let(:params) do
            {
              manage_user: true,
              user: 'A1234',
              group: 'A1234',
              uid: 10_000,
              gid: 10_000
            }
          end

          it { is_expected.to contain_group('A1234').with(ensure: 'present', gid: 10_000) }
          it { is_expected.to contain_user('A1234').with(ensure: 'present', gid: 10_000, uid: 10_000) }
        end

        context 'with java_package set and java_ensure => latest' do
          let(:params) do
            {
              java_package: 'openjdk-11-jre-headless',
              java_ensure: 'latest'
            }
          end

          it { is_expected.to contain_package('openjdk-11-jre-headless').with_ensure('latest') }
        end

        context 'with jna_package set and jna_ensure => 3.0' do
          let(:params) do
            {
              jna_package: 'libjna-java',
              jna_ensure: '3.0'
            }
          end

          it { is_expected.to contain_package('libjna-java').with_ensure('3.0') }
        end
      end
    end
  end
end
