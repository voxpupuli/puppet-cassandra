require 'spec_helper'
describe 'cassandra::private::firewall_ports::rule' do
  let(:pre_condition) do
    ['define firewall ($action, $dport, $proto, $source) {}']
  end

  context 'Test that rules can be set.' do
    let(:title) { '200_Public_0.0.0.0/0' }
    let :params do
      {
        ports: [8888, 22]
      }
    end

    it do
      should contain_firewall('200 - Cassandra (Public) - 0.0.0.0/0').with(
        action: 'accept',
        dport: [8888, 22],
        proto: 'tcp',
        source: '0.0.0.0/0'
      )
      should have_resource_count(2)
    end
  end
end
