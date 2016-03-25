require 'spec_helper'

describe 'cassandra::schema::table' do
  let(:pre_condition) do
    [
      'define ini_setting($ensure = nil,
         $path,
         $section,
         $key_val_separator       = nil,
         $setting,
         $value                   = nil) {}'
    ]
  end

  let!(:stdlib_stubs) do
    MockFunction.new('count') do |f|
      f.stubbed.with(
        [
          'COMPACT STORAGE',
          'ID=\'5a1c395e-b41f-11e5-9f22-ba0be0483c18\''
        ]).returns(2)
    end
    MockFunction.new('delete') do |f|
      # rubocop:disable Metrics/LineLength
      f.stubbed.with('userid text, username FROZEN<fullname>, emails set<text>, top_scores list<int>, todo map<timestamp, text>, COLLECTION-TYPE tuple<int, text,text>, PRIMARY KEY (userid)', 'COLLECTION-TYPE ').returns('userid text, username FROZEN<fullname>, emails set<text>, top_scores list<int>, todo map<timestamp, text>, tuple<int, text,text>, PRIMARY KEY (userid)')
      # rubocop:enable Metrics/LineLength
    end
    MockFunction.new('join') do |f|
      # rubocop:disable Metrics/LineLength
      f.stubbed.with(
        [
          'COMPACT STORAGE', 'ID=\'5a1c395e-b41f-11e5-9f22-ba0be0483c18\''
        ], ' AND ').returns("COMPACT STORAGE AND ID='5a1c395e-b41f-11e5-9f22-ba0be0483c18'")
      f.stubbed.with(
        [
          'userid text', 'username FROZEN<fullname>', 'emails set<text>',
          'top_scores list<int>', 'todo map<timestamp, text>',
          'COLLECTION-TYPE tuple<int, text,text>', 'PRIMARY KEY (userid)'
        ], ', ').returns('userid text, username FROZEN<fullname>, emails set<text>, top_scores list<int>, todo map<timestamp, text>, COLLECTION-TYPE tuple<int, text,text>, PRIMARY KEY (userid)')
      # rubocop:enable Metrics/LineLength
    end
    MockFunction.new('join_keys_to_values') do |f|
      f.stubbed.with(
        {
          'userid' => 'text', 'username' => 'FROZEN<fullname>',
          'emails' => 'set<text>', 'top_scores' => 'list<int>',
          'todo' => 'map<timestamp, text>',
          'COLLECTION-TYPE' => 'tuple<int, text,text>',
          'PRIMARY KEY' => '(userid)'
        }, ' ').returns(
          [
            'userid text', 'username FROZEN<fullname>', 'emails set<text>',
            'top_scores list<int>', 'todo map<timestamp, text>',
            'COLLECTION-TYPE tuple<int, text,text>', 'PRIMARY KEY (userid)'
          ])
    end
  end

  context 'Create Table' do
    let :facts do
      {
        osfamily: 'RedHat'
      }
    end

    let(:title) { 'users' }

    let(:params) do
      {
        keyspace: 'Excelsior',
        columns:
          {
            'userid' => 'text',
            'username' => 'FROZEN<fullname>',
            'emails' => 'set<text>',
            'top_scores' => 'list<int>',
            'todo' => 'map<timestamp, text>',
            'COLLECTION-TYPE' => 'tuple<int, text,text>',
            'PRIMARY KEY' => '(userid)'
          },
        options:
          [
            'COMPACT STORAGE',
            'ID=\'5a1c395e-b41f-11e5-9f22-ba0be0483c18\''
          ]
      }
    end

    it do
      should compile
      # rubocop:disable Metrics/LineLength
      should contain_exec('/usr/bin/cqlsh   -e "CREATE TABLE IF NOT EXISTS Excelsior.users (userid text, username FROZEN<fullname>, emails set<text>, top_scores list<int>, todo map<timestamp, text>, tuple<int, text,text>, PRIMARY KEY (userid)) WITH COMPACT STORAGE AND ID=\'5a1c395e-b41f-11e5-9f22-ba0be0483c18\'"  ')
      # rubocop:enable Metrics/LineLength
    end
  end

  context 'Drop Table' do
    let :facts do
      {
        osfamily: 'RedHat'
      }
    end

    let(:title) { 'users' }

    let(:params) do
      {
        keyspace: 'Excelsior',
        ensure: 'absent'
      }
    end

    it do
      should compile
      # rubocop:disable Metrics/LineLength
      should contain_exec('/usr/bin/cqlsh   -e "DROP TABLE IF EXISTS Excelsior.users"  ')
      # rubocop:enable Metrics/LineLength
    end
  end

  context 'Set ensure to latest' do
    let :facts do
      {
        osfamily: 'RedHat'
      }
    end

    let(:title) { 'foobar' }
    let(:params) do
      {
        ensure: 'latest'
      }
    end

    it { should raise_error(Puppet::Error) }
  end
end
