# frozen_string_literal: true

require 'spec_helper'

describe 'cassandra::system::sysctl' do
  context 'Test the default parameters (RedHat)' do
    let :facts do
      {
        osfamily: 'RedHat',
        operatingsystemmajrelease: '7',
        os: {
          'family' => 'RedHat',
          'release' => {
            'full' => '7.6.1810',
            'major' => '7',
            'minor' => '6'
          }
        }
      }
    end

    it do
      expect(subject).to have_resource_count(9)
      expect(subject).to contain_class('Cassandra::System::Sysctl')
      expect(subject).to contain_ini_setting('net.core.optmem_max = 40960')
      expect(subject).to contain_ini_setting('net.core.rmem_default = 16777216')
      expect(subject).to contain_ini_setting('net.core.rmem_max = 16777216')
      expect(subject).to contain_ini_setting('net.core.wmem_default = 16777216')
      expect(subject).to contain_ini_setting('net.core.wmem_max = 16777216')
      expect(subject).to contain_ini_setting('net.ipv4.tcp_rmem = 4096, 87380, 16777216')
      expect(subject).to contain_ini_setting('net.ipv4.tcp_wmem = 4096, 65536, 16777216')
      expect(subject).to contain_ini_setting('vm.max_map_count = 1048575')
      expect(subject).to contain_exec('Apply sysctl changes').with(
        command: '/sbin/sysctl -p /etc/sysctl.d/10-cassandra.conf'
      )
    end
  end
end
