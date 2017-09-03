require 'spec_helper'
describe 'cassandra::apache_repo' do
  let(:pre_condition) do
    [
      'class apt () {}',
      'class apt::update () {}',
      'define apt::key ($id, $source) {}',
      'define apt::source ($location, $comment, $release, $include) {}'
    ]
  end

  context 'On a RedHat OS with defaults for all parameters' do
    let :facts do
      {
        osfamily: 'RedHat'
      }
    end

    let :params do
      {
        release: '311x'
      }
    end

    it do
      should have_resource_count(1)

      should contain_class('cassandra::apache_repo').only_with(
        'descr'   => 'Repo for Apache Cassandra',
        'key_id'  => 'A26E528B271F19B9E5D8E19EA278B781FE4B2BDA',
        'key_url' => 'https://www.apache.org/dist/cassandra/KEYS',
        'release' => '311x'
      )

      should contain_yumrepo('cassandra_apache').with(
        ensure: 'present',
        descr: 'Repo for Apache Cassandra',
        baseurl: 'http://www.apache.org/dist/cassandra/redhat/311x',
        enabled: 1,
        gpgcheck: 1,
        gpgkey: 'https://www.apache.org/dist/cassandra/KEYS'
      )
    end
  end

  context 'On a Debian OS with defaults for all parameters' do
    let :facts do
      {
        osfamily: 'Debian',
        lsbdistid: 'Ubuntu',
        lsbdistrelease: '14.04'
      }
    end

    it do
      should have_resource_count(3)
      should contain_class('apt')
      should contain_class('apt::update')

      should contain_apt__key('apache.cassandra').with(
        id: 'A26E528B271F19B9E5D8E19EA278B781FE4B2BDA',
        source: 'https://www.apache.org/dist/cassandra/KEYS'
      )

      should contain_apt__source('cassandra.sources').with(
        location: 'http://www.apache.org/dist/cassandra/debian',
        comment: 'Repo for Apache Cassandra',
        release: 'main',
        include: { 'src' => false }
      ).that_notifies('Exec[update-apache-cassandra-repo]')

      should contain_exec('update-apache-cassandra-repo').with(
        refreshonly: true,
        command: '/bin/true'
      )
    end
  end
end
