require 'spec_helper'
describe 'cassandra::datastax_repo' do
  let(:pre_condition) do
    [
      'class apt () {}',
      'class apt::update () {}',
      'define apt::key ($id, $source) {}',
      'define apt::source ($location, $comment, $release, $include) {}'
    ]
  end

  context 'Regardless of which OS' do
    it do
      should compile
      should have_resource_count(0)

      should contain_class('cassandra::datastax_repo').only_with(
        'descr'   => 'DataStax Repo for Apache Cassandra',
        'key_id'  => '7E41C00F85BFC1706C4FFFB3350200F2B999A372',
        'key_url' => 'http://debian.datastax.com/debian/repo_key',
        'pkg_url' => nil,
        'release' => 'stable'
      )
    end
  end

  context 'On a RedHat OS with defaults for all parameters' do
    let :facts do
      {
        osfamily: 'RedHat'
      }
    end

    it do
      should have_resource_count(1)

      should contain_yumrepo('datastax').with(
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
        osfamily: 'Debian',
        lsbdistid: 'Ubuntu',
        lsbdistrelease: '14.04'
      }
    end

    it do
      should have_resource_count(3)
      should contain_class('apt')
      should contain_class('apt::update')

      should contain_apt__key('datastaxkey').with(
        id: '7E41C00F85BFC1706C4FFFB3350200F2B999A372',
        source: 'http://debian.datastax.com/debian/repo_key'
      )

      should contain_apt__source('datastax').with(
        location: 'http://debian.datastax.com/community',
        comment: 'DataStax Repo for Apache Cassandra',
        release: 'stable',
        include: { 'src' => false }
      ).that_notifies('Exec[update-cassandra-repos]')

      should contain_exec('update-cassandra-repos').with(
        refreshonly: true,
        command: '/bin/true'
      )
    end
  end
end
