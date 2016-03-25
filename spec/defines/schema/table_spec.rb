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
    MockFunction.new('join') do |f|
      f.stubbed.with(['firstname text', 'lastname text'], ', ')
       .returns('firstname text, lastname text')
    end
    MockFunction.new('join_keys_to_values') do |f|
      f.stubbed.with({'userid' => 'text', 'username' => 'FROZEN<fullname>', 'emails' => 'set<text>', 'top_scores' => 'list<int>', 'todo' => 'map<timestamp, text>', 'COLLECTION-TYPE' => 'tuple<int, text,text>', 'PRIMARY KEY' => '(userid)'}, ' ')
       .returns(['userid text', 'username FROZEN<fullname>', 'emails set<text>', 'top_scores list<int>', 'todo map<timestamp, text>', 'COLLECTION-TYPE tuple<int, text,text>', 'PRIMARY KEY (userid)'])
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
        'keyspace' => 'Excelsior',
        columns:
          {
            'userid' => 'text',
            'username'  => 'FROZEN<fullname>',
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

    it { should compile }
  end
end
