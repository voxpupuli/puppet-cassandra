# frozen_string_literal: true

require 'spec_helper'

describe 'cassandra::system::swapoff' do
  context 'Test the default parameters' do
    it do
      expect(subject).to have_resource_count(1)
      expect(subject).to contain_class('cassandra::system::swapoff')
      expect(subject).to contain_exec('Disable Swap')
    end
  end

  context 'Test we can remove a swap device from /etc/fstab' do
    let :params do
      {
        device: '/dev/mapper/centos-swap'
      }
    end

    it do
      expect(subject).to have_resource_count(2)
      expect(subject).to contain_class('cassandra::system::swapoff')
      expect(subject).to contain_exec('Disable Swap')
      expect(subject).to contain_mount('swap').with(
        ensure: 'absent',
        device: '/dev/mapper/centos-swap',
        fstype: 'swap'
      )
    end
  end
end
