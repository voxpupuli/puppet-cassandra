require 'spec_helper_acceptance'

describe 'cassandra class' do
  cassandra_upgrade22_pp = <<-EOS
    if $::osfamily == 'RedHat' and $::operatingsystemmajrelease == 7 {
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

    class { 'cassandra::optutils':
      package_ensure => $version,
      package_name   => $cassandra_optutils_package,
      require        => Class['cassandra']
    }

    $heap_new_size = $::processorcount * 100

    class { 'cassandra::file':
      file       => 'cassandra-env.sh',
      file_lines => {
        'MAX_HEAP_SIZE' => {
          line  => 'MAX_HEAP_SIZE="1024M"',
          match => '#MAX_HEAP_SIZE="4G"',
        },
        'HEAP_NEWSIZE' => {
          line  => "HEAP_NEWSIZE='${heap_new_size}M'",
          match => '#HEAP_NEWSIZE="800M"',
        }
      }
    }
  EOS

  describe '########### Cassandra 2.2 installation.' do
    it 'should work with no errors' do
      apply_manifest(cassandra_upgrade22_pp, catch_failures: true)
    end
    it 'check code is idempotent' do
      expect(apply_manifest(cassandra_upgrade22_pp,
                            catch_failures: true).exit_code).to be_zero
    end
  end

  describe service('cassandra') do
    it { is_expected.to be_running }
    it { is_expected.to be_enabled }
  end
end
