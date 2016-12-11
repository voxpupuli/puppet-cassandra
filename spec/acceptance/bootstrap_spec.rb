require 'spec_helper_acceptance'

describe 'Bootstrap' do
  bootstrap_pp = <<-EOS
    case downcase($::operatingsystem) {
      'centos': {
        if $::operatingsystemmajrelease == 6 {
          exec { '/bin/cp /opt/rh/ruby200/enable /etc/profile.d/ruby.sh': } ->
          exec { '/bin/rm /usr/bin/ruby /usr/bin/gem': } ->
          exec { '/usr/sbin/alternatives --install /usr/bin/ruby ruby /opt/rh/ruby200/root/usr/bin/ruby 1000': } ->
          exec { '/usr/sbin/alternatives --install /usr/bin/gem gem /opt/rh/ruby200/root/usr/bin/gem 1000': }
        }
      }
      'ubuntu': {
        if $::operatingsystemmajrelease == 12.04 {
          package {'python-software-properties':} ->
          exec {'/usr/bin/apt-add-repository ppa:brightbox/ruby-ng':} ->
          exec {'/usr/bin/apt-get update': } ->
          package {'ruby2.0': } ->
          exec { '/bin/rm /usr/bin/ruby': } ->
          exec { '/usr/sbin/update-alternatives --install /usr/bin/ruby ruby /usr/bin/ruby2.0 1000': }
        }
      }
    }
  EOS

  describe '########### Node specific manifest.' do
    it 'should work with no errors' do
      apply_manifest(bootstrap_pp, catch_failures: true)
      shell('[ -d /opt/rh/ruby200 ] && /usr/bin/gem install puppet -v 3.8.7 --no-rdoc --no-ri; true')
    end
  end
end
