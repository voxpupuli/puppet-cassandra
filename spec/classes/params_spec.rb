# frozen_string_literal: true

require 'spec_helper'

describe 'cassandra::params' do
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
    expect(subject).to compile
    expect(subject).to contain_class('cassandra::params')
    expect(subject).to have_resource_count(0)
  end
end
