require 'spec_helper_acceptance'

roles = hosts[0]['roles']
version = 2.2
t = TestManifests.new(roles, version)
firewall_pp = t.firewall_pp()
cassandra_install_pp = t.cassandra_install_pp(firewall_pp)
schema_create_pp = t.schema_create_pp()
facts_testing_pp = t.facts_testing_pp(cassandra_install_pp)
cassandra_uninstall_pp = t.cassandra_uninstall_pp()

describe 'Cassandra 2.2', if roles.include? 'cassandra2'
                            describe 'Cassandra 2.2 installation.' do
                              it 'should work with no errors' do
                                apply_manifest(cassandra_install_pp, catch_failures: true)
                              end

                              it 'check code is idempotent' do
                                expect(apply_manifest(cassandra_install_pp,
                                                      catch_failures: true).exit_code).to be_zero
                              end
                            end

                            describe 'Schema create 2.2.' do
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
                              it 'check service status' do
                                is_expected.to be_running
                                is_expected.to be_enabled
                              end
                            end

                            if fact('osfamily') == 'RedHat'
                              describe service('datastax-agent') do
                                it 'check service status' do
                                  is_expected.to be_running
                                  is_expected.to be_enabled
                                end
                              end
                            end

                            describe 'Facts Tests 2.2.' do
                              it 'should work with no errors' do
                                apply_manifest(facts_testing_pp, catch_failures: true)
                              end
                            end

                            describe 'Gather service information (when in debug mode) 2.2.' do
                              it 'Show the cassandra system log.' do
                                shell("grep -v -e '^INFO' -e '^\s*INFO' /var/log/cassandra/system.log")
                              end
                            end

                            describe 'Uninstall Cassandra 2.2' do
                              it 'should work with no errors' do
                                apply_manifest(cassandra_uninstall_pp, catch_failures: true)
                              end
                            end
                          end
