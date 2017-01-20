require 'spec_helper'

describe 'cassandra::system::sysctl' do
  let(:pre_condition) do
    [
      'define ini_setting($ensure = nil,
         $path,
         $section,
         $key_val_separator = nil,
         $setting,
         $value             = nil) {}'
    ]
  end

  context 'Test the default parameters (RedHat)' do
    let :facts do
      {
        osfamily: 'RedHat',
        operatingsystemmajrelease: 7
      }
    end

    it do
      should have_resource_count(9)
      should contain_class('Cassandra::System::Sysctl')
      should contain_ini_setting('net.core.optmem_max = 40960')
      should contain_ini_setting('net.core.rmem_default = 16777216')
      should contain_ini_setting('net.core.rmem_max = 16777216')
      should contain_ini_setting('net.core.wmem_default = 16777216')
      should contain_ini_setting('net.core.wmem_max = 16777216')
      should contain_ini_setting('net.ipv4.tcp_rmem = 4096, 87380, 16777216')
      should contain_ini_setting('net.ipv4.tcp_wmem = 4096, 65536, 16777216')
      should contain_ini_setting('vm.max_map_count = 1048575')
      should contain_exec('Apply sysctl changes').with(
        command: '/sbin/sysctl -p /etc/sysctl.d/10-cassandra.conf'
      )
    end
  end
end
