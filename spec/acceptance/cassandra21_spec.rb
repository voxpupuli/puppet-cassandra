require 'spec_helper_acceptance'
require_relative 'test_manifests'

osfamily = fact('osfamily')
roles = hosts[0]['roles']
version = 2.1
t = TestManifests.new(roles, version)
firewall_pp = t.firewall_pp()
cassandra_install_pp = t.cassandra_install_pp(firewall_pp)
schema_create_pp = t.schema_create_pp()
facts_testing_pp = t.facts_testing_pp(cassandra_install_pp)
cassandra_uninstall_pp = t.cassandra_uninstall_pp()

describe 'cassandra2', unless: CASSANDRA2_UNSUPPORTED_PLATFORMS.include?(fact('lsbdistrelease')) do
  describe '########### Cassandra installation.' do
    it 'should work with no errors' do
      apply_manifest(cassandra_install_pp, catch_failures: true)
    end

    it 'check code is idempotent' do
      expect(apply_manifest(cassandra_install_pp,
                            catch_failures: true).exit_code).to be_zero
    end
  end

  describe '########### Schema create.' do
    pp = <<-EOS
      #{cassandra_install_pp}
      #{schema_create_pp}
    EOS

    it 'should work with no errors' do
      apply_manifest(pp, catch_failures: true)
    end

    it 'check code is idempotent' do
      expect(apply_manifest(pp, catch_failures: true).exit_code).to be_zero
    end
  end

  describe service('cassandra') do
    it do
      is_expected.to be_running
      is_expected.to be_enabled
    end
  end

  describe service('datastax-agent') do
    it do
      is_expected.to be_running
      is_expected.to be_enabled
    end
  end

  describe '########### Facts Tests.' do
    it 'should work with no errors' do
      apply_manifest(facts_testing_pp, catch_failures: true)
    end
  end

  describe '########### Gather service information (when in debug mode).' do
    it 'Show the cassandra system log.' do
      shell("grep -v -e '^INFO' -e '^\s*INFO' /var/log/cassandra/system.log")
    end
  end

  describe '########### Uninstall Cassandra 2.' do
    it 'should work with no errors' do
      apply_manifest(cassandra_uninstall_pp, catch_failures: true)
    end
  end
end


# describe "Install Cassandra #{version}" do
#   t = TestManifests.new(roles, version)
#   firewall_pp = t.firewall_pp()
#   cassandra_install_pp = t.cassandra_install_pp(firewall_pp)
#   schema_create_pp = t.schema_create_pp()
#
#   pp = <<-EOS
#     #{cassandra_install_pp}
#     #{schema_create_pp}
#   EOS
#
#   it "Install Cassandra #{version}" do
#     apply_manifest(pp, catch_failures: true)
#   end
#
#   it "Test installation idempotency for Cassandra #{version}" do
#     expect(apply_manifest(pp, catch_failures: true).exit_code).to be_zero
#   end
# end
#
# describe 'Facts Tests.' do
#   t = TestManifests.new(roles, version)
#   firewall_pp = t.firewall_pp()
#   cassandra_install_pp = t.cassandra_install_pp(firewall_pp)
#   facts_testing_pp = t.facts_testing_pp(cassandra_install_pp)
#
#   it 'should work with no errors' do
#     apply_manifest(facts_testing_pp, catch_failures: true)
#   end
# end
#
# describe service('cassandra') do
#   it do
#     is_expected.to be_running
#     is_expected.to be_enabled
#   end
# end
#
# if osfamily == 'RedHat'
#   describe service('datastax-agent') do
#     it do
#       is_expected.to be_running
#       is_expected.to be_enabled
#     end
#   end
# end
#
# describe "Uninstall Cassandra #{version}." do
#   t = TestManifests.new(roles, version)
#   cassandra_uninstall_pp = t.cassandra_uninstall_pp()
#   # shell("grep -v -e '^INFO' -e '^\s*INFO' /var/log/cassandra/system.log")
#   apply_manifest(cassandra_uninstall_pp, catch_failures: true)
# end
