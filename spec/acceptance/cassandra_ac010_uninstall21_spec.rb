require 'spec_helper_acceptance'

describe 'cassandra class' do
  cassandra_uninstall21_pp = <<-EOS
    if $::osfamily == 'RedHat' {
        $cassandra_optutils_package = 'cassandra21-tools'
        $cassandra_package = 'cassandra21'
    } else {
        $cassandra_optutils_package = 'cassandra-tools'
        $cassandra_package = 'cassandra'
    }

    package { [$cassandra_optutils_package, $cassandra_package ]:
      ensure => absent
    }
  EOS

  describe '########### Uninstall Cassandra 2.1.' do
    it 'should work with no errors' do
      apply_manifest(cassandra_uninstall21_pp, catch_failures: true)
    end
  end
end
