require 'spec_helper_acceptance'

describe 'cassandra::dse class' do
  dse_mock_pp = <<-EOS
    $str = "#export DSE_HOME\n# export HADOOP_LOG_DIR=<log_dir>"

    file { '/etc/dse':
      ensure => directory,
    } ->
    file { '/etc/dse/dse-env.sh':
      ensure  => present,
      content => $str,
    }
  EOS

  describe '########### Mock a DSE Installation.' do
    it 'should work with no errors' do
      apply_manifest(dse_mock_pp, catch_failures: true)
    end
  end

  cassandra_install_pp = <<-EOS
    if $::osfamily == 'RedHat' and $::operatingsystemmajrelease == 7 {
      $service_systemd = true
    } else {
      $service_systemd = false
    }

    if $::osfamily == 'RedHat' {
      $cassandra_package = 'cassandra20'
      $version = '2.0.17-1'

      class { 'cassandra::java':
        before => Class['cassandra']
      }
    } else {
      if $::lsbdistid == 'Ubuntu' {
        class { 'cassandra::java':
          aptkey       => {
            'openjdk-r' => {
              id     => 'DA1A4A13543B466853BAF164EB9B1D8886F44E2A',
              server => 'keyserver.ubuntu.com',
            },
          },
          aptsource    => {
            'openjdk-r' => {
              location => 'http://ppa.launchpad.net/openjdk-r/ppa/ubuntu',
              comment  => 'OpenJDK builds (all archs)',
              release  => $::lsbdistcodename,
              repos    => 'main',
            },
          },
          package_name => 'openjdk-8-jdk',
        }
      } else {
        class { 'cassandra::java':
          aptkey       => {
            'ZuluJDK' => {
              id     => '27BC0C8CB3D81623F59BDADCB1998361219BD9C9',
              server => 'keyserver.ubuntu.com',
            },
          },
          aptsource    => {
            'ZuluJDK' => {
              location => 'http://repos.azulsystems.com/debian',
              comment  => 'Zulu OpenJDK 8 for Debian',
              release  => 'stable',
              repos    => 'main',
            },
          },
          package_name => 'zulu-8',
        }
      }

      $cassandra_package = 'cassandra'
      $version = '2.0.17'

      exec { '/bin/chown root:root /etc/apt/sources.list.d/datastax.list':
        unless  => '/usr/bin/test -O /etc/apt/sources.list.d/datastax.list',
        require => Class['cassandra::datastax_agent']
      }
    }

    class { 'cassandra::datastax_repo': } ->
    file { '/var/lib/cassandra':
      ensure => directory,
    } ->
    file { '/var/lib/cassandra/commitlog':
      ensure => directory,
    } ->
    file { '/var/lib/cassandra/caches':
      ensure => directory,
    } ->
    file { [ '/var/lib/cassandra/data' ]:
      ensure => directory,
    } ->
    class { 'cassandra':
      authenticator               => 'PasswordAuthenticator',
      cassandra_9822              => true,
      cassandra_yaml_tmpl         => 'cassandra/cassandra20.yaml.erb',
      commitlog_directory_mode    => '0770',
      data_file_directories_mode  => '0770',
      dc                          => 'LON',
      rack                        => 'R101',
      package_ensure              => $version,
      package_name                => $cassandra_package,
      saved_caches_directory_mode => '0770',
      service_systemd             => $service_systemd
    }

    class { '::cassandra::datastax_agent':
      service_systemd => $service_systemd,
      require         => Class['cassandra']
    }

    class { 'cassandra::dse':
      file_lines => {
        'Set HADOOP_LOG_DIR directory' => {
          ensure => present,
          path   => '/etc/dse/dse-env.sh',
          line   => 'export HADOOP_LOG_DIR=/var/log/hadoop',
          match  => '^# export HADOOP_LOG_DIR=<log_dir>',
        },
        'Set DSE_HOME'                 => {
          ensure => present,
          path   => '/etc/dse/dse-env.sh',
          line   => 'export DSE_HOME=/usr/share/dse',
          match  => '^#export DSE_HOME',
        },
      },
      settings   => {
        ldap_options => {
          server_host                => localhost,
          server_port                => 389,
          search_dn                  => 'cn=Admin',
          search_password            => secret,
          use_ssl                    => false,
          use_tls                    => false,
          truststore_type            => jks,
          user_search_base           => 'ou=users,dc=example,dc=com',
          user_search_filter         => '(uid={0})',
          credentials_validity_in_ms => 0,
          connection_pool            => {
            max_active => 8,
            max_idle   => 8,
          }
        }
      }
    }
  EOS

  describe '########### DSE settings.' do
    it 'should work with no errors' do
      apply_manifest(cassandra_install_pp, catch_failures: true)
    end
    it 'check code is idempotent' do
      expect(apply_manifest(cassandra_install_pp,
                            catch_failures: true).exit_code).to be_zero
    end
  end
end
