require 'spec_helper'

describe 'cassandra::schema::user' do
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

  context 'Create a user' do
    let :facts do
      {
        osfamily: 'RedHat'
      }
    end

    let(:title) { 'akers' }

    let(:params) do
      {
        password: 'Niner2',
        superuser: true
      }
    end

    it do
      should contain_exec('/usr/bin/cqlsh   -e "CREATE USER IF NOT EXISTS akers WITH PASSWORD \'Niner2\' SUPERUSER"  ')
    end
  end

  context 'Drop a user' do
    let :facts do
      {
        osfamily: 'RedHat'
      }
    end

    let(:title) { 'akers' }

    let(:params) do
      {
        password: 'Niner2',
        ensure: 'absent'
      }
    end

    it do
      should contain_exec('/usr/bin/cqlsh   -e "DROP USER akers"  ')
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
