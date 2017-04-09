require 'spec_helper_acceptance'
describe 'cassandra' do
  roles = hosts[0]['roles']
  versions = []
  versions.push(2.1) if roles.include? 'cassandra2'
  versions.push(2.2) if roles.include? 'cassandra2'
  versions.push(3.0) if roles.include? 'cassandra3'

  firewall_pp = if roles.include? 'firewall'
                  "include '::cassandra::firewall_ports'"
                else
                  '# Firewall test skipped'
                end

  versions.each do |version|
    if version == 2.1
      debian_release = '21x'
      debian_package_ensure = '2.1.17'
      redhat_package_ensure = '2.1.15-1'
      cassandra_optutils_package = 'cassandra21-tools'
      cassandra_package = 'cassandra21'
    elsif version == 2.2
      debian_release = '23x'
      debian_package_ensure = '2.2.9'
      redhat_package_ensure = '2.2.8-1'
      cassandra_optutils_package = 'cassandra22-tools'
      cassandra_package = 'cassandra22'
    elsif version == 3.0
      debian_release = '30x'
      debian_package_ensure = '3.0.12'
      redhat_package_ensure = '3.0.9-1'
      cassandra_optutils_package = 'cassandra30-tools'
      cassandra_package = 'cassandra30'
    end

    test_cassandra_dse_pp = <<-EOS
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

    cassandra_install_pp = <<-EOS
      if $::osfamily == 'Debian' {
        class { 'cassandra::apache_repo':
          release => '#{debian_release}',
          before  => Class['cassandra', 'cassandra::optutils'],
        }

        $package_ensure = '#{debian_package_ensure}'
        $cassandra_package = '#{cassandra_package}'
        $cassandra_optutils_package = '#{cassandra_optutils_package}'
      } else {
        require cassandra::datastax_repo
        $package_ensure = '#{redhat_package_ensure}'
        $cassandra_package = 'cassandra'
        $cassandra_optutils_package = 'cassandra-tools'
      }

      require cassandra::java
      require cassandra::system::swapoff
      require cassandra::system::transparent_hugepage

      if versioncmp($::rubyversion, '1.9.0') < 0 {
        $service_refresh = false
      } else {
        $service_refresh = true
      }

      if #{version} >= 3.0 {
        class { 'cassandra':
          hints_directory => '/var/lib/cassandra/hints',
          package_ensure  => $package_ensure,
          package_name    => $cassandra_package,
          service_refresh => $service_refresh,
        }
      } else {
        class { 'cassandra':
          package_ensure  => $package_ensure,
          package_name    => $cassandra_package,
          service_refresh => $service_refresh,
        }
      }

      if $::lsbdistid == 'Ubuntu' {
        if $::operatingsystemmajrelease >= 16 {
          # Workarounds for amonst other things CASSANDRA-11850
          Exec {
            environment => [ 'CQLSH_NO_BUNDLED=TRUE' ]
          }
        }
      }

      class { 'cassandra::optutils':
        package_ensure => $package_ensure,
        package_name   => $cassandra_optutils_package,
        require        => Class['cassandra']
      }

      if $::osfamily == 'RedHat' {
        class { 'cassandra::datastax_agent':
          require => Class['cassandra']
        }
      }

      #{firewall_pp}
      #{test_cassandra_dse_pp}
    EOS

    it "Install Cassandra #{version}" do
      apply_manifest(cassandra_install_pp, catch_failures: true)
      expect(apply_manifest(cassandra_install_pp, catch_failures: true).exit_code).to be_zero
    end
  end
end
