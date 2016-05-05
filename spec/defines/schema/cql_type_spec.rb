require 'spec_helper'

describe 'cassandra::schema::cql_type' do
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
      f.stubbed.with({ 'firstname' => 'text', 'lastname' => 'text' }, ' ')
       .returns(['firstname text', 'lastname text'])
    end
  end

  context 'CQL TYPE (fullname)' do
    let :facts do
      {
        osfamily: 'RedHat'
      }
    end

    let(:title) { 'fullname' }

    let(:params) do
      {
        'keyspace' => 'Excelsior',
        fields:
          {
            'firstname' => 'text',
            'lastname'  => 'text'
          }
      }
    end

    it { should compile }
    it { should contain_class('cassandra::schema') }
    it { should contain_cassandra__schema__cql_type('fullname') }
    it do
      should contain_exec('/usr/bin/cqlsh   -e "CREATE TYPE IF NOT EXISTS Excelsior.fullname (firstname text, lastname text)"  ')
    end
  end

  context 'Set ensure to absent' do
    let :facts do
      {
        osfamily: 'RedHat'
      }
    end

    let(:title) { 'address' }
    let(:params) do
      {
        'ensure'   => 'absent',
        'keyspace' => 'Excalibur'
      }
    end

    it { should contain_cassandra__schema__cql_type('address') }

    it do
      should compile
      should contain_exec('/usr/bin/cqlsh   -e "DROP type Excalibur.address"  ')
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
