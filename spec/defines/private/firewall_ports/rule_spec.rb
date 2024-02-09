# frozen_string_literal: true

require 'spec_helper'
describe 'cassandra::private::firewall_ports::rule' do
  context 'Test that rules can be set.' do
    let(:title) { '200_Public_0.0.0.0/0' }
    let :params do
      {
        ports: [8888, 22]
      }
    end

    it do
      expect(subject).to contain_firewall('200 - Cassandra (Public) - 0.0.0.0/0').with(
        action: 'accept',
        dport: [8888, 22],
        proto: 'tcp',
        source: '0.0.0.0/0'
      )
      expect(subject).to have_resource_count(2)
    end
  end
end
