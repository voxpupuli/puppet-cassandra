require 'spec_helper_acceptance'

describe 'cassandra class' do
  schema_testing_drop_type_pp = <<-EOS
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
      'fullname' => {
        'keyspace' => 'mykeyspace',
        'ensure'   => 'absent'
      }
    }

    if $::operatingsystem != CentOS {
      $os_ok = true
    } else {
      if $::operatingsystemmajrelease != 6 {
        $os_ok = true
      } else {
        $os_ok = false
      }
    }

    if $os_ok {
      class { 'cassandra::schema':
        cql_types      => $cql_types,
        cqlsh_user     => 'akers',
        cqlsh_password => 'Niner2',
      }
    }
  EOS

  describe '########### Schema drop type.' do
    it 'should work with no errors' do
      apply_manifest(schema_testing_drop_type_pp,
                     catch_failures: true)
    end
    it 'check code is idempotent' do
      expect(apply_manifest(schema_testing_drop_type_pp,
                            catch_failures: true).exit_code).to be_zero
    end
  end
end
