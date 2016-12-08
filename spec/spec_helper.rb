require 'rubygems'
require 'rspec-puppet'
require 'rspec-puppet-utils'
require 'puppetlabs_spec_helper/module_spec_helper'
require 'simplecov'
require 'coveralls' unless ENV['TRAVIS'] == 'true'

Coveralls.wear! unless ENV['TRAVIS'] == 'true'
fixture_path = File.expand_path(File.join(__FILE__, '..', 'fixtures'))

RSpec.configure do |config|
  config.module_path = File.join(fixture_path, 'modules')
  config.manifest_dir = File.join(fixture_path, 'manifests')
  config.tty = true
  config.mock_with :rspec
  config.raise_errors_for_deprecations!

  config.before(:each) do
    MockFunction.new('concat') do |f|
      f.stubbed.returns([8888, 22])
      f.stubbed.with([], '/etc/cassandra')
       .returns(['/etc/cassandra'])
      f.stubbed.with([], '/etc/cassandra/default.conf')
       .returns(['/etc/cassandra/default.conf'])
      f.stubbed.with(['/etc/cassandra'], '/etc/cassandra/default.conf')
       .returns(['/etc/cassandra', '/etc/cassandra/default.conf'])
    end

    MockFunction.new('count') do |f|
      f.stubbed.with(
        [
          'COMPACT STORAGE',
          'ID=\'5a1c395e-b41f-11e5-9f22-ba0be0483c18\''
        ]
      ).returns(2)
    end

    MockFunction.new('create_ini_settings', type: :statement) do |f|
    end

    MockFunction.new('delete') do |f|
      f.stubbed.with(
        {
          'keyspace_class' => 'NetworkTopologyStrategy',
          'dc1' => '3',
          'dc2' => '2'
        },
        'keyspace_class'
      ).returns('dc1' => '3', 'dc2' => '2')
      f.stubbed.with('userid text, username FROZEN<fullname>, emails set<text>, top_scores list<int>, todo map<timestamp, text>, COLLECTION-TYPE tuple<int, text,text>, PRIMARY KEY (userid)', 'COLLECTION-TYPE ').returns('userid text, username FROZEN<fullname>, emails set<text>, top_scores list<int>, todo map<timestamp, text>, tuple<int, text,text>, PRIMARY KEY (userid)')
    end

    MockFunction.new('is_array') do |f|
      f.stubbed.with('').returns(false)
      f.stubbed.with(['/var/lib/cassandra/data']).returns(true)
    end

    MockFunction.new('join') do |f|
      f.stubbed.with(['firstname text', 'lastname text'], ', ')
       .returns('firstname text, lastname text')
      f.stubbed.with(
        {
          '\'dc1\': ' => '3',
          '\'dc2\': ' => '2'
        },
        ', '
      ).returns('\'dc1\': 3, \'dc2\': 2')
      f.stubbed.with(
        [
          'COMPACT STORAGE', 'ID=\'5a1c395e-b41f-11e5-9f22-ba0be0483c18\''
        ], ' AND '
      ).returns("COMPACT STORAGE AND ID='5a1c395e-b41f-11e5-9f22-ba0be0483c18'")
      f.stubbed.with(
        [
          'userid text', 'username FROZEN<fullname>', 'emails set<text>',
          'top_scores list<int>', 'todo map<timestamp, text>',
          'COLLECTION-TYPE tuple<int, text,text>', 'PRIMARY KEY (userid)'
        ], ', '
      ).returns('userid text, username FROZEN<fullname>, emails set<text>, top_scores list<int>, todo map<timestamp, text>, COLLECTION-TYPE tuple<int, text,text>, PRIMARY KEY (userid)')
    end

    MockFunction.new('join_keys_to_values') do |f|
      f.stubbed.with({ 'firstname' => 'text', 'lastname' => 'text' }, ' ')
       .returns(['firstname text', 'lastname text'])
      f.stubbed.with(
        {
          '\'dc1' => '3',
          '\'dc2' => '2'
        },
        '\': '
      ).returns('\'dc1\': ' => '3', '\'dc2\': ' => '2')
      f.stubbed.with(
        {
          'userid' => 'text', 'username' => 'FROZEN<fullname>',
          'emails' => 'set<text>', 'top_scores' => 'list<int>',
          'todo' => 'map<timestamp, text>',
          'COLLECTION-TYPE' => 'tuple<int, text,text>',
          'PRIMARY KEY' => '(userid)'
        }, ' '
      ).returns(
        [
          'userid text', 'username FROZEN<fullname>', 'emails set<text>',
          'top_scores list<int>', 'todo map<timestamp, text>',
          'COLLECTION-TYPE tuple<int, text,text>', 'PRIMARY KEY (userid)'
        ]
      )
    end

    MockFunction.new('merge') do |f|
    end

    MockFunction.new('prefix') do |f|
      f.stubbed.with(['0.0.0.0/0'],
                     '200_Public_').returns('200_Public_0.0.0.0/0')
      f.stubbed.with(['0.0.0.0/0'],
                     '210_InterNode_').returns('210_InterNode__0.0.0.0/0')
      f.stubbed.with(['0.0.0.0/0'],
                     '220_Client_').returns('220_Client__0.0.0.0/0')
      f.stubbed.with(
        {
          'dc1' => '3',
          'dc2' => '2'
        }, '\''
      ).returns('\'dc1' => '3', '\'dc2' => '2')
    end

    MockFunction.new('upcase') do |f|
      f.stubbed.with('ALL').returns('ALL')
      f.stubbed.with('ALTER').returns('ALTER')
      f.stubbed.with('AUTHORIZE').returns('AUTHORIZE')
      f.stubbed.with('CREATE').returns('CREATE')
      f.stubbed.with('DROP').returns('DROP')
      f.stubbed.with('MODIFY').returns('MODIFY')
      f.stubbed.with('SELECT').returns('SELECT')
      f.stubbed.with('field').returns('FIELD')
      f.stubbed.with('forty9ers').returns('FORTY9ERS')
      f.stubbed.with('ravens').returns('ravens')
    end

    MockFunction.new('size') do |f|
      f.stubbed.returns(42)
    end

    MockFunction.new('strftime') do |f|
      f.stubbed.with('/var/lib/cassandra-%F')
       .returns('/var/lib/cassandra-YYYY-MM-DD')
    end

    MockFunction.new('validate_hash', type: :statement) do |f|
    end
  end

  config.after(:suite) do
    exit(1) if RSpec::Puppet::Coverage.report!(100)
  end
end
