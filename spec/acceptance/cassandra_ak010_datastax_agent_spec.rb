require 'spec_helper_acceptance'

describe 'cassandra::datastax_agent class' do
  datastax_agent_install_pp = <<-EOS
    class { '::cassandra::datastax_agent':
      settings       => {
        'agent_alias'     => {
          'value' => 'foobar',
        },
        'stomp_interface' => {
           'value' => 'localhost',
        },
        'async_pool_size' => {
          ensure => absent,
        }
      },
      service_systemd => false,
    }
  EOS

  describe '########### DataStax Agent installation.' do
    it 'should work with no errors' do
      apply_manifest(datastax_agent_install_pp, catch_failures: true)
    end
    it 'check code is idempotent' do
      expect(apply_manifest(datastax_agent_install_pp,
                            catch_failures: true).exit_code).to be_zero
    end
  end

  describe service('datastax-agent') do
    it { is_expected.to be_running }
    it { is_expected.to be_enabled }
  end
end
