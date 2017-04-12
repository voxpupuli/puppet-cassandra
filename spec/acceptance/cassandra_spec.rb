require 'spec_helper_acceptance'

describe 'Cassanda Puppet Module' do
  roles = hosts[0]['roles']
  versions = []
  versions.push(2.1) if roles.include? 'cassandra2'
  versions.push(2.2) if roles.include? 'cassandra2'
  versions.push(3.0) if roles.include? 'cassandra3'
  osfamily = fact('osfamily')

  firewall_pp = if roles.include? 'firewall'
                  "include '::cassandra::firewall_ports'"
                else
                  '# Firewall test skipped'
                end

  bootstrap_pp = <<-EOS
    Exec {
      path => [
       '/usr/local/bin',
       '/opt/local/bin',
       '/usr/bin',
       '/usr/sbin',
       '/bin',
       '/sbin'],
       logoutput => true,
    }

    notify { "${::operatingsystem}-${::operatingsystemmajrelease}": }

    file { '/etc/dse':
      ensure => directory,
    } ->
    file { '/etc/dse/dse-env.sh':
      ensure  => present,
      content => "#export DSE_HOME\n# export HADOOP_LOG_DIR=<log_dir>",
    }

    case downcase("${::operatingsystem}-${::operatingsystemmajrelease}") {
      'centos-6': {
        package { ['gcc', 'tar', 'yum-utils', 'centos-release-scl']: } ->
        exec { 'yum-config-manager --enable rhel-server-rhscl-7-rpms': } ->
        package { ['ruby200', 'python27']: } ->
        exec { 'cp /opt/rh/python27/enable /etc/profile.d/python.sh': } ->
        exec { 'echo "\n" >> /etc/profile.d/python.sh': } ->
        exec { 'echo "export PYTHONPATH=/usr/lib/python2.7/site-packages" >> /etc/profile.d/python.sh': } ->
        exec { '/bin/cp /opt/rh/ruby200/enable /etc/profile.d/ruby.sh': } ->
        exec { '/bin/rm /usr/bin/ruby /usr/bin/gem': } ->
        exec { '/usr/sbin/alternatives --install /usr/bin/ruby ruby /opt/rh/ruby200/root/usr/bin/ruby 1000': } ->
        exec { '/usr/sbin/alternatives --install /usr/bin/gem gem /opt/rh/ruby200/root/usr/bin/gem 1000': }
      }
      'centos-7': {
        package { ['gcc', 'tar', 'initscripts']: }
      }
      'debian-7': {
        package { ['sudo', 'ufw', 'wget']: }
      }
      'debian-8': {
        package { ['locales-all', 'net-tools', 'sudo', 'ufw']: } ->
        file { '/usr/sbin/policy-rc.d':
          ensure => absent,
        }
      }
      'ubuntu-12.04': {
        package {['python-software-properties', 'iptables', 'sudo']:} ->
        exec {'/usr/bin/apt-add-repository ppa:brightbox/ruby-ng':} ->
        exec {'/usr/bin/apt-get update': } ->
        package {'ruby2.0': } ->
        exec { '/bin/rm /usr/bin/ruby': } ->
        exec { '/usr/sbin/update-alternatives --install /usr/bin/ruby ruby /usr/bin/ruby2.0 1000': }
      }
      'ubuntu-16.04': {
        package { ['locales-all', 'net-tools', 'sudo', 'ufw']: } ->
        file { '/usr/sbin/policy-rc.d':
          ensure => absent,
        }
      }
    }
  EOS

  it "Initial test preparation (#{osfamily})" do
    apply_manifest(bootstrap_pp, catch_failures: true)
    shell('[ -d /opt/rh/ruby200 ] && /usr/bin/gem install puppet -v 3.8.7 --no-rdoc --no-ri; true')
  end

  versions.each do |version|
    if version == 2.1
      debian_release = '21x'
      debian_package_ensure = '2.1.17'
      redhat_package_ensure = '2.1.15-1'
      cassandra_optutils_package = 'cassandra21-tools'
      cassandra_package = 'cassandra21'
    elsif version == 2.2
      debian_release = '22x'
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

    cassandra_install_pp = <<-EOS
      if $::osfamily == 'Debian' {
        class { 'cassandra::apache_repo':
          release => '#{debian_release}',
          before  => Class['cassandra', 'cassandra::optutils'],
        }

        $package_ensure = '#{debian_package_ensure}'
        $cassandra_package = 'cassandra'
        $cassandra_optutils_package = 'cassandra-tools'
      } else {
        class { 'cassandra::datastax_repo':
          before  => Class['cassandra', 'cassandra::optutils'],
        }
        $package_ensure = '#{redhat_package_ensure}'
        $cassandra_package = '#{cassandra_package}'
        $cassandra_optutils_package = '#{cassandra_optutils_package}'
      }

      require cassandra::system::swapoff
      require cassandra::system::transparent_hugepage
      include cassandra::java

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
          require         => Class['cassandra::java'],
        }
      } else {
        class { 'cassandra':
          package_ensure  => $package_ensure,
          package_name    => $cassandra_package,
          service_refresh => $service_refresh,
          require         => Class['cassandra::java'],
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
      include cassandra::dse
    EOS

    schema_create_pp = <<-EOS
      #{cassandra_install_pp}
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
      class { 'cassandra::schema':
        cql_types      => $cql_types,
        cqlsh_password => 'cassandra',
        cqlsh_user     => 'cassandra',
        indexes        => {
          'users_lname_idx' => {
            keyspace => 'mykeyspace',
            table    => 'users',
            keys     => 'lname',
          },
        },
        keyspaces      => $keyspaces,
        tables         => {
          'users' => {
            'keyspace' => 'mykeyspace',
            'columns'  => {
              'userid'      => 'int',
              'fname'       => 'text',
              'lname'       => 'text',
              'PRIMARY KEY' => '(userid)',
            },
          },
        },
        permissions    => {
          'Grant select permissions to spillman to all keyspaces' => {
            permission_name => 'SELECT',
            user_name       => 'spillman',
          },
          'Grant modify to to keyspace mykeyspace to akers'       => {
            keyspace_name   => 'mykeyspace',
            permission_name => 'MODIFY',
            user_name       => 'akers',
          },
          'Grant alter permissions to mykeyspace to boone'        => {
            keyspace_name   => 'mykeyspace',
            permission_name => 'ALTER',
            user_name       => 'boone',
          },
          'Grant ALL permissions to mykeyspace.users to gbennet'  => {
            keyspace_name   => 'mykeyspace',
            permission_name => 'ALTER',
            table_name      => 'users',
            user_name       => 'gbennet',
          },
        },
        users          => {
          'akers'    => {
            password  => 'Niner2',
            superuser => true,
          },
          'boone'    => {
            password => 'Niner75',
          },
          'gbennet' => {
            password => 'Strewth',
          },
          'spillman' => {
            password => 'Niner27',
          },
        },
      }
    EOS

    cassandra_uninstall_pp = <<-EOS
      Exec {
        path => [
          '/usr/bin',
          '/bin' ],
        logoutput => true,
      }
      if $::osfamily == 'RedHat' {
        $cassandra_optutils_package = '#{cassandra_optutils_package}'
        $cassandra_package = '#{cassandra_package}'
      } else {
        $cassandra_optutils_package = 'cassandra-tools'
        $cassandra_package = 'cassandra'
      }
      service { 'cassandra':
        ensure => stopped,
      } ->
      package { $cassandra_optutils_package:
        ensure => purged,
      } ->
      package { $cassandra_package:
        ensure => purged,
      } ->
      exec { 'rm -rf /var/lib/cassandra/*/* /var/log/cassandra/*': }
    EOS

    pp = <<-EOS
      #{cassandra_install_pp}
      #{schema_create_pp}
    EOS

    it "Install Cassandra #{version}" do
      apply_manifest(pp, catch_failures: true)
    end

    it "Test installation idempotency for Cassandra #{version}" do
      expect(apply_manifest(pp, catch_failures: true).exit_code).to be_zero
    end

    describe service('cassandra') do
      it do
        is_expected.to be_running
        is_expected.to be_enabled
      end
    end

    it "########### Uninstall Cassandra #{version}." do
      apply_manifest(cassandra_uninstall_pp, catch_failures: true)
    end
  end
end
