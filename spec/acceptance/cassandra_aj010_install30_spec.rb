require 'spec_helper_acceptance'

describe 'cassandra class' do
  cassandra_upgrade30_pp = <<-EOS
     if $::osfamily == 'RedHat' and $::operatingsystemmajrelease == 7 {
         $service_systemd = true
     } else {
         $service_systemd = false
     }

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
       listen_interface            => 'lo',
       package_ensure              => $version,
       package_name                => $cassandra_package,
       rpc_interface               => 'lo',
       saved_caches_directory_mode => '0770',
     }

     class { 'cassandra::optutils':
       ensure       => $version,
       package_name => $cassandra_optutils_package,
       require      => Class['cassandra']
     }
   EOS

  describe '########### Cassandra 3.0 installation.' do
    it 'should work with no errors' do
      apply_manifest(cassandra_upgrade30_pp, catch_failures: true)
    end

    it 'Give Cassandra 3.0 a minute to fully come alive.' do
      sleep 60
    end

    it 'check code is idempotent' do
      expect(apply_manifest(cassandra_upgrade30_pp,
                            catch_failures: true).exit_code).to be_zero
    end
  end

  describe service('cassandra') do
    it { is_expected.to be_running }
    it { is_expected.to be_enabled }
  end
end
