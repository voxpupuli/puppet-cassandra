# frozen_string_literal: true

require 'spec_helper'
describe 'cassandra::datastax_repo' do
  context 'On a RedHat OS with defaults for all parameters' do
    let :facts do
      {
        os: {
          'family' => 'RedHat',
        }
      }
    end

    it do
      expect(subject).to have_resource_count(1)

      expect(subject).to contain_class('cassandra::datastax_repo').only_with(
        'descr' => 'DataStax Repo for Apache Cassandra',
        'key_id' => '7E41C00F85BFC1706C4FFFB3350200F2B999A372',
        'key_url' => 'http://debian.datastax.com/debian/repo_key',
        'release' => 'stable'
      )

      expect(subject).to contain_yumrepo('datastax').with(
        ensure: 'present',
        descr: 'DataStax Repo for Apache Cassandra',
        baseurl: 'http://rpm.datastax.com/community',
        enabled: 1,
        gpgcheck: 0
      )
    end
  end

  context 'On a Debian OS with defaults for all parameters' do
    let :facts do
      {
        os: {
          'family' => 'Debian',
        }
      }
    end

    it do
      expect(subject).to contain_class('apt')
      expect(subject).to contain_class('apt::update')

      expect(subject).to contain_apt__key('datastaxkey').with(
        id: '7E41C00F85BFC1706C4FFFB3350200F2B999A372',
        source: 'http://debian.datastax.com/debian/repo_key'
      )

      expect(subject).to contain_apt__source('datastax').with(
        location: 'http://debian.datastax.com/community',
        comment: 'DataStax Repo for Apache Cassandra',
        release: 'stable',
        include: { 'src' => false }
      ).that_notifies('Exec[update-cassandra-repos]')

      expect(subject).to contain_exec('update-cassandra-repos').with(
        refreshonly: true,
        command: '/bin/true'
      )
    end
  end
end
