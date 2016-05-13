require 'spec_helper_acceptance'

describe 'cassandra class' do
  check_against_previous_version_pp = <<-EOS
    if $::osfamily == 'RedHat' {
      $cassandra_optutils_package = 'cassandra30-tools'
      $cassandra_package = 'cassandra30'
      $version = '3.0.3-1'
    } else {
      $cassandra_optutils_package = 'cassandra-tools'
      $cassandra_package = 'cassandra'
      $version = '3.0.3'
    }

    class { 'cassandra':
      authenticator               => 'PasswordAuthenticator',
      cassandra_9822              => true,
      commitlog_directory_mode    => '0770',
      data_file_directories_mode  => '0770',
      hints_directory             => '/var/lib/cassandra/hints',
      package_ensure              => $version,
      package_name                => $cassandra_package,
      saved_caches_directory_mode => '0770',
    }
  EOS

  describe '########### Ensure config file does get updated.' do
    it 'Initial install manifest again' do
      apply_manifest(check_against_previous_version_pp,
                     catch_failures: true)
    end
    it 'Copy the current module to the side without error.' do
      shell('cp -R /etc/puppet/modules/cassandra /var/tmp',
            acceptable_exit_codes: 0)
    end
    it 'Remove the current module without error.' do
      shell('puppet module uninstall locp-cassandra',
            acceptable_exit_codes: 0)
    end
    it 'Install the latest module from the forge.' do
      shell('puppet module install locp-cassandra',
            acceptable_exit_codes: 0)
    end
    it 'Check install works without changes with previous module version.' do
      expect(apply_manifest(check_against_previous_version_pp,
                            catch_failures: true).exit_code).to be_zero
    end
  end
end
