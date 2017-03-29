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

      should contain_apt__key('apachekey').with(
        id: 'A26E528B271F19B9E5D8E19EA278B781FE4B2BDA',
        source: 'https://www.apache.org/dist/cassandra/KEYS'
      )

      should contain_apt__source('apache').with(
        location: 'http://www.apache.org/dist/cassandra/debian',
        comment: 'Repo for Apache Cassandra',
        release: '310x',
        include: { 'src' => false }
      ).that_notifies('Exec[update-cassandra-repos]')

      should contain_exec('update-cassandra-repos').with(
        refreshonly: true,
        command: '/bin/true'
      )
    end
  end
end
