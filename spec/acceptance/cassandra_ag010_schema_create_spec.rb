require 'spec_helper_acceptance'

describe 'cassandra class' do
  schema_testing_create_pp = <<-EOS
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
        'fields'   => {
          'fname' => 'text',
          'lname' => 'text',
        },
      },
    }

    $keyspaces = {
      'mykeyspace' => {
        ensure          => present,
        replication_map => {
          keyspace_class     => 'SimpleStrategy',
          replication_factor => 1,
        },
        durable_writes  => false,
      },
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
        cqlsh_password => 'cassandra',
        cqlsh_user     => 'cassandra',
        indexes   => {
          'users_lname_idx' => {
             keyspace => 'mykeyspace',
             table    => 'users',
             keys     => 'lname',
          },
        },
        keyspaces => $keyspaces,
        tables    => {
          'users' => {
            'keyspace' => 'mykeyspace',
            'columns'       => {
              'userid'      => 'int',
              'fname'       => 'text',
              'lname'       => 'text',
              'PRIMARY KEY' => '(userid)',
            },
          },
        },
        users     => {
          'spillman' => {
            password => 'Niner27',
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

  describe '########### Schema create.' do
    it 'should work with no errors' do
      apply_manifest(schema_testing_create_pp, catch_failures: true)
    end
    it 'check code is idempotent' do
      expect(apply_manifest(schema_testing_create_pp,
                            catch_failures: true).exit_code).to be_zero
    end
  end
end
