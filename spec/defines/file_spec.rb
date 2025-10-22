# frozen_string_literal: true

require 'spec_helper'

describe 'cassandra::file' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'set max and new heap size' do
        let(:title) { 'cassandra-env.sh' }

        let(:params) do
          {
            file_lines: {
              'MAX_HEAP_SIZE' => {
                'line' => 'MAX_HEAP_SIZE=4G',
                'match' => '^#?MAX_HEAP_SIZE=.*'
              },
              'HEAP_NEWSIZE' => {
                'line'  => 'HEAP_NEWSIZE=300M',
                'match' => '^#?HEAP_NEWSIZE=.*'
              }
            }
          }
        end

        it { is_expected.to compile.with_all_deps }

        it do
          is_expected.to contain_cassandra__file('cassandra-env.sh').
            with(
              file_lines: {
                'MAX_HEAP_SIZE' => {
                  'line' => 'MAX_HEAP_SIZE=4G',
                  'match' => '^#?MAX_HEAP_SIZE=.*'
                },
                'HEAP_NEWSIZE' => {
                  'line'  => 'HEAP_NEWSIZE=300M',
                  'match' => '^#?HEAP_NEWSIZE=.*'
                }
              }
            )
        end

        it { is_expected.to contain_file_line('MAX_HEAP_SIZE').with(line: 'MAX_HEAP_SIZE=4G', match: '^#?MAX_HEAP_SIZE=.*', notify: 'Service[cassandra]') }
        it { is_expected.to contain_file_line('HEAP_NEWSIZE').with(line: 'HEAP_NEWSIZE=300M', match: '^#?HEAP_NEWSIZE=.*', notify: 'Service[cassandra]') }
      end

      context 'set max heap size with service_refresh => false' do
        let(:pre_condition) do
          <<-HERE
          class { 'cassandra':
            service_refresh => false,
          }
          HERE
        end

        let(:title) { 'cassandra-env.sh' }

        let(:params) do
          {
            file_lines: {
              'MAX_HEAP_SIZE' => {
                'line' => 'MAX_HEAP_SIZE=20G',
                'match' => '^#?MAX_HEAP_SIZE=.*'
              }
            }
          }
        end

        it { is_expected.to compile.with_all_deps }

        it do
          is_expected.to contain_cassandra__file('cassandra-env.sh').
            with(
              file_lines: {
                'MAX_HEAP_SIZE' => {
                  'line' => 'MAX_HEAP_SIZE=20G',
                  'match' => '^#?MAX_HEAP_SIZE=.*'
                }
              }
            )
        end

        it { is_expected.to contain_file_line('MAX_HEAP_SIZE').with(line: 'MAX_HEAP_SIZE=20G', match: '^#?MAX_HEAP_SIZE=.*', notify: nil) }
      end

      context 'set heap_newsize with different config_path' do
        let(:pre_condition) do
          <<-HERE
          class { 'cassandra':
            config_path => '/tmp/conf',
            manage_config_file => false,
            manage_snitch_file => false
          }
          HERE
        end

        let(:title) { 'cassandra-env.sh' }

        let(:params) do
          {
            file_lines: {
              'HEAP_NEWSIZE' => {
                'line'  => 'HEAP_NEWSIZE=300M',
                'match' => '^#?HEAP_NEWSIZE=.*'
              }
            }
          }
        end

        it { is_expected.to compile.with_all_deps }

        it do
          is_expected.to contain_file('/tmp/conf').with(
            ensure: 'directory',
            owner: 'cassandra',
            group: 'cassandra',
            mode: '0755'
          )
          is_expected.to contain_cassandra__file('cassandra-env.sh').
            with(
              file_lines: {
                'HEAP_NEWSIZE' => {
                  'line'  => 'HEAP_NEWSIZE=300M',
                  'match' => '^#?HEAP_NEWSIZE=.*'
                }
              }
            )
        end

        it { is_expected.to contain_file_line('HEAP_NEWSIZE').with(line: 'HEAP_NEWSIZE=300M', match: '^#?HEAP_NEWSIZE=.*', path: '/tmp/conf/cassandra-env.sh') }
      end
    end
  end
end
