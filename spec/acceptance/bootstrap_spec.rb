require 'spec_helper_acceptance'

describe 'Bootstrap' do
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
      'ubuntu-14.04': {
        package {['systemd', 'iptables', 'sudo']:} ->
        file { '/bin/systemctl':
          ensure => absent,
        } ->
        file { '/bin/true':
          ensure => link,
          target => '/bin/systemctl',
        }
      }
      'ubuntu-16.04': {
        package { ['locales-all', 'net-tools', 'sudo', 'ufw', 'ntp', 'python-pip', 'python-minimal']: } ->
        file { '/usr/sbin/policy-rc.d':
          ensure => absent,
        } ->
        exec { '/usr/bin/wget http://launchpadlibrarian.net/109052632/python-support_1.0.15_all.deb':
          cwd => '/var/tmp',
        } ->
        exec { '/usr/bin/dpkg -i python-support_1.0.15_all.deb':
          cwd => '/var/tmp',
        } ->
        package { 'cassandra-driver':
          provider => 'pip',
        }
      }
    }
  EOS

  describe 'Node specific manifest.' do
    it 'should work with no errors' do
      apply_manifest(bootstrap_pp, catch_failures: true)
    end
  end
end
