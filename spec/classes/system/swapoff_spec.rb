require 'spec_helper'

describe 'cassandra::system::swapoff' do
  context 'Test the default parameters' do
    it do
      should have_resource_count(1)
      should contain_class('cassandra::system::swapoff')
      should contain_exec('Disable Swap')
    end
  end

  context 'Test we can remove a swap device from /etc/fstab' do
    let :params do
      {
        device: '/dev/mapper/centos-swap'
      }
    end

    it do
      should have_resource_count(2)
      should contain_class('cassandra::system::swapoff')
      should contain_exec('Disable Swap')
      should contain_mount('swap').with(
        ensure: 'absent',
        device: '/dev/mapper/centos-swap',
        fstype: 'swap'
      )
    end
  end
end
