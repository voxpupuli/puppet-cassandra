require 'spec_helper'
describe 'cassandra::private::firewall_ports::rule' do
  let(:pre_condition) do
    ['define firewall ($action, $dport, $proto, $source) {}']
  end

  let!(:stdlib_stubs) do
    MockFunction.new('prefix') do |f|
      f.stubbed.with(['0.0.0.0/0'],
                     '200_Public_').returns('200_Public_0.0.0.0/0')
      f.stubbed.with(['0.0.0.0/0'],
                     '210_InterNode_').returns('210_InterNode__0.0.0.0/0')
      f.stubbed.with(['0.0.0.0/0'],
                     '220_Client_').returns('220_Client__0.0.0.0/0')
    end
    MockFunction.new('concat') { |f| f.stubbed.returns([8888, 22]) }
    MockFunction.new('size') { |f| f.stubbed.returns(42) }
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
