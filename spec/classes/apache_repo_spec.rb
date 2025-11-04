# frozen_string_literal: true

require 'spec_helper'
describe 'cassandra::apache_repo' do
  context 'On a RedHat OS with defaults for all parameters' do
    let :facts do
      {
        os: {
          'family' => 'RedHat'
        }
      }
    end

    let :params do
      {
        release: '311x'
      }
    end

    it do
      expect(subject).to have_resource_count(1)

      expect(subject).to contain_class('cassandra::apache_repo').only_with(
        'descr' => 'Repo for Apache Cassandra',
        'key_id' => 'A26E528B271F19B9E5D8E19EA278B781FE4B2BDA',
        'key_url' => 'https://www.apache.org/dist/cassandra/KEYS',
        'release' => '311x'
      )

      expect(subject).to contain_yumrepo('cassandra_apache').with(
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
        os: {
          'family' => 'Debian'
        }
      }
    end

    it do
      expect(subject).to contain_class('apt')
      expect(subject).to contain_class('apt::update')

      expect(subject).to contain_apt__key('apache.cassandra').with(
        id: 'A26E528B271F19B9E5D8E19EA278B781FE4B2BDA',
        source: 'https://www.apache.org/dist/cassandra/KEYS'
      )

      expect(subject).to contain_apt__source('cassandra.sources').with(
        location: 'http://www.apache.org/dist/cassandra/debian',
        comment: 'Repo for Apache Cassandra',
        release: 'main',
        include: { 'src' => false }
      ).that_notifies('Exec[update-apache-cassandra-repo]')

      expect(subject).to contain_exec('update-apache-cassandra-repo').with(
        refreshonly: true,
        command: '/bin/true'
      )
    end
  end
end
