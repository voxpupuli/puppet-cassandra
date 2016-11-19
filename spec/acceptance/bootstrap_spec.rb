require 'spec_helper_acceptance'

describe 'Bootstrap' do
  whoami_pp = <<-EOS
    notify { "operatingsystem:           ${::operatingsystem}": } ->
    notify { "operatingsystemmajrelease: ${::operatingsystemmajrelease}": }
  EOS

  describe '########### Identify the node.' do
    it 'should work with no errors' do
      apply_manifest(whoami_pp, catch_failures: true)
    end
  end

  bootstrap_pp = <<-EOS
    case downcase($::operatingsystem) {
      'centos': {
        if $::operatingsystemmajrelease == 6 {
          package {'yum-utils': } ->
          package {'centos-release-scl': } ->
          exec { '/usr/bin/yum-config-manager --enable rhel-server-rhscl-7-rpms': } ->
          package {'ruby200': } ->
          exec { '/bin/cp /opt/rh/ruby200/enable /etc/profile.d/ruby.sh': } ->
          exec { '/bin/rm /usr/bin/ruby /usr/bin/gem': } ->
          exec { '/usr/sbin/alternatives --install /usr/bin/ruby ruby /opt/rh/ruby200/root/usr/bin/ruby 1000': } ->
          exec { '/usr/sbin/alternatives --install /usr/bin/gem gem /opt/rh/ruby200/root/usr/bin/gem 1000': }
        }
      }
      'ubuntu': {
        if $::operatingsystemmajrelease >= 16 {
          package { 'locales-all': } ->
          package { 'net-tools': } ->
          package { 'sudo': } ->
          package { 'ufw': } ->
          package { 'wget': } ->
          package { 'ntp': } ->
          package { 'python-pip': } ->
          package { 'python-minimal': } ->
          exec { '/bin/rm -f /usr/sbin/policy-rc.d': } ->
          exec { '/usr/bin/wget http://launchpadlibrarian.net/109052632/python-support_1.0.15_all.deb':
            cwd     => '/var/tmp',
            creates => '/var/tmp/python-support_1.0.15_all.deb',
          } ~>
          exec { '/usr/bin/dpkg -i /var/tmp/python-support_1.0.15_all.deb': } ->
          package { 'cassandra-driver':
            provider => 'pip',
          }
        }
      }
    }
  EOS

  describe '########### Bootstrap' do
    it 'should work with no errors' do
      apply_manifest(bootstrap_pp, catch_failures: true)
      shell('[ -d /opt/rh/ruby200 ] && /usr/bin/gem install puppet -v 3.8.7 --no-rdoc --no-ri; true')
    end
  end
end
