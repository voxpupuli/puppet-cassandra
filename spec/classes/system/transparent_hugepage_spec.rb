# frozen_string_literal: true

require 'spec_helper'

describe 'cassandra::system::transparent_hugepage' do
  context 'Test the default parameters (RedHat)' do
    let :facts do
      {
        os: {
          'family' => 'RedHat',
        }
      }
    end

    it do
      expect(subject).to have_resource_count(1)
      expect(subject).to contain_class('cassandra::system::transparent_hugepage')
      expect(subject).to contain_exec('Disable Java Hugepages')
    end
  end

  context 'Test the default parameters (Debian)' do
    let :facts do
      {
        os: {
          'family' => 'Debian',
        }
      }
    end

    it do
      expect(subject).to have_resource_count(1)
      expect(subject).to contain_class('cassandra::system::transparent_hugepage')
      expect(subject).to contain_exec('Disable Java Hugepages')
    end
  end
end
