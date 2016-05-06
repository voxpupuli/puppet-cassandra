require 'spec_helper'
describe 'cassandra::firewall_ports' do
  let(:pre_condition) do
    [
      'class cassandra () {}',
      'define firewall ($action, $dport, $proto, $source) {}'
    ]
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
    MockFunction.new('concat') do |f|
      f.stubbed.returns([8888, 22])
    end
    MockFunction.new('size') do |f|
      f.stubbed.returns(42)
    end
  end

  context 'Run with defaults.' do
    it { should have_resource_count(2) }

    it do
      should contain_class('cassandra::firewall_ports')
        .with('client_ports' => [9042, 9160],
              'client_subnets'      => ['0.0.0.0/0'],
              'inter_node_ports'    => [7000, 7001, 7199],
              'inter_node_subnets'  => ['0.0.0.0/0'],
              'public_ports'        => [8888],
              'public_subnets'      => ['0.0.0.0/0'],
              'ssh_port'            => 22,
              'opscenter_ports'     => [9042, 9160, 61_620, 61_621],
              'opscenter_subnets'   => ['0.0.0.0/0'])
    end

    it { should contain_firewall('200 - Cassandra (Public) - 0.0.0.0/0') }

    it do
      should contain_cassandra__private__firewall_ports__rule('200_Public_0.0.0.0/0')
        .with('ports' => [8888, 22])
    end
  end
end
