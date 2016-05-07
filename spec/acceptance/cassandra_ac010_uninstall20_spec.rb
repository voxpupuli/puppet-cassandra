require 'spec_helper_acceptance'

describe 'cassandra class' do
  cassandra_uninstall20_pp = <<-EOS
    if $::osfamily == 'RedHat' {
        $cassandra_optutils_package = 'cassandra20-tools'
        $cassandra_package = 'cassandra20'
    } else {
        $cassandra_optutils_package = 'cassandra-tools'
        $cassandra_package = 'cassandra'
    }

    package { [$cassandra_optutils_package, $cassandra_package ]:
      ensure => absent
    }
  EOS

  describe '########### Uninstall Cassandra 2.0.' do
    it 'should work with no errors' do
      apply_manifest(cassandra_uninstall20_pp, catch_failures: true)
    end
  end
end
