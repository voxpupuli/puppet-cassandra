require 'spec_helper_acceptance'

describe 'cassandra class' do
  schema_testing_drop__index_and_cql_type_pp = <<-EOS
    if $::osfamily == 'RedHat' and $::operatingsystemmajrelease == 7 {
        $service_systemd = true
    } elsif $::operatingsystem == 'Debian' and $::operatingsystemmajrelease == 8 {
        $service_systemd = true
    } else {
        $service_systemd = false
    }

    if $::osfamily == 'RedHat' {
        $cassandra_optutils_package = 'cassandra22-tools'
        $cassandra_package = 'cassandra22'
        $version = '2.2.5-1'
    } else {
        $cassandra_optutils_package = 'cassandra-tools'
        $cassandra_package = 'cassandra'
        $version = '2.2.5'
    }

    class { 'cassandra':
      authenticator               => 'PasswordAuthenticator',
      cassandra_9822              => true,
      commitlog_directory_mode    => '0770',
      data_file_directories_mode  => '0770',
      listen_interface            => 'lo',
      package_ensure              => $version,
      package_name                => $cassandra_package,
      rpc_interface               => 'lo',
      saved_caches_directory_mode => '0770',
      service_systemd             => $service_systemd
    }

    $cql_types = {
      'address' => {
        'keyspace' => 'Excalibur',
        'ensure'   => 'absent'
      }
    }

    if $::operatingsystem != CentOS and $::operatingsystemmajrelease != 6 {
      class { 'cassandra::schema':
        cql_types      => $cql_types,
        cqlsh_user     => 'akers',
        cqlsh_password => 'Niner2',
        indexes        => {
          'users_emails_idx' => {
             ensure   => absent,
             keyspace => 'Excalibur',
             table    => 'users',
          },
        },
        users          => {
          'spillman' => {
            ensure   => absent,
          },
          'akers'    => {
            password  => 'Niner2',
            superuser => true,
          },
          'boone'    => {
            password => 'Niner75',
          },
        },
      }
    }
  EOS

  describe '########### Schema drop (Indexes, Users & Types).' do
    it 'should work with no errors' do
      apply_manifest(schema_testing_drop__index_and_cql_type_pp,
                     catch_failures: true)
    end
    it 'check code is idempotent' do
      expect(apply_manifest(schema_testing_drop__index_and_cql_type_pp,
                            catch_failures: true).exit_code).to be_zero
    end
  end

  schema_testing_drop_user_pp = <<-EOS
    if $::osfamily == 'RedHat' and $::operatingsystemmajrelease == 7 {
        $service_systemd = true
    } elsif $::operatingsystem == 'Debian' and $::operatingsystemmajrelease == 8 {
        $service_systemd = true
    } else {
        $service_systemd = false
    }

    if $::osfamily == 'RedHat' {
        $cassandra_optutils_package = 'cassandra22-tools'
        $cassandra_package = 'cassandra22'
        $version = '2.2.5-1'
    } else {
        $cassandra_optutils_package = 'cassandra-tools'
        $cassandra_package = 'cassandra'
        $version = '2.2.5'
    }

    class { 'cassandra':
      authenticator               => 'PasswordAuthenticator',
      cassandra_9822              => true,
      commitlog_directory_mode    => '0770',
      data_file_directories_mode  => '0770',
      listen_interface            => 'lo',
      package_ensure              => $version,
      package_name                => $cassandra_package,
      rpc_interface               => 'lo',
      saved_caches_directory_mode => '0770',
      service_systemd             => $service_systemd
    }

    if $::operatingsystem != CentOS and $::operatingsystemmajrelease != 6 {
      class { 'cassandra::schema':
        cqlsh_password      => 'Niner2',
        cqlsh_user          => 'akers',
        cqlsh_client_config => '/root/.puppetcqlshrc',
        users               => {
          'boone' => {
            ensure => absent,
          },
        },
      }
    }
  EOS

  describe '########### Drop the boone user.' do
    it 'should work with no errors' do
      apply_manifest(schema_testing_drop_user_pp, catch_failures: true)
    end
    it 'check code is idempotent' do
      expect(apply_manifest(schema_testing_drop_user_pp,
                            catch_failures: true).exit_code).to be_zero
    end
  end

  schema_testing_drop_pp = <<-EOS
    if $::osfamily == 'RedHat' and $::operatingsystemmajrelease == 7 {
        $service_systemd = true
    } elsif $::operatingsystem == 'Debian' and $::operatingsystemmajrelease == 8 {
        $service_systemd = true
    } else {
        $service_systemd = false
    }

    if $::osfamily == 'RedHat' {
        $cassandra_optutils_package = 'cassandra22-tools'
        $cassandra_package = 'cassandra22'
        $version = '2.2.5-1'
    } else {
        $cassandra_optutils_package = 'cassandra-tools'
        $cassandra_package = 'cassandra'
        $version = '2.2.5'
    }

    class { 'cassandra':
      authenticator               => 'PasswordAuthenticator',
      cassandra_9822              => true,
      commitlog_directory_mode    => '0770',
      data_file_directories_mode  => '0770',
      listen_interface            => 'lo',
      package_ensure              => $version,
      package_name                => $cassandra_package,
      rpc_interface               => 'lo',
      saved_caches_directory_mode => '0770',
      service_systemd             => $service_systemd
    }

    $keyspaces = {
      'Excelsior' => {
        ensure => absent,
      }
    }

    if $::operatingsystem != CentOS and $::operatingsystemmajrelease != 6 {
      class { 'cassandra::schema':
        cqlsh_password => 'Niner2',
        cqlsh_user     => 'akers',
        keyspaces      => $keyspaces,
      }
    }
  EOS

  describe '########### Schema drop (Keyspaces).' do
    it 'should work with no errors' do
      apply_manifest(schema_testing_drop_pp, catch_failures: true)
    end
    it 'check code is idempotent' do
      expect(apply_manifest(schema_testing_drop_pp,
                            catch_failures: true).exit_code).to be_zero
    end
  end
end
