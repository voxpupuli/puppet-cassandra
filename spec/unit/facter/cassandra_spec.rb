require 'spec_helper'

describe 'Facter::Util::Fact' do
  before do
    Facter.clear
  end

  describe 'cassandrarelease DSE' do
    it do
      allow(Facter::Util::Resolution)
        .to receive(:exec).with('nodetool version')
        .and_return('2.1.11.969')
      expect(Facter.fact(:cassandrarelease).value).to eql('2.1.11')
      expect(Facter.fact(:cassandramajorversion).value).to eql(2)
      expect(Facter.fact(:cassandraminorversion).value).to eql(1)
      expect(Facter.fact(:cassandrapatchversion).value).to eql(11)
    end
  end

  describe 'cassandrarelease DDC' do
    it do
      allow(Facter::Util::Resolution)
        .to receive(:exec).with('nodetool version')
        .and_return('3.0.1')
      expect(Facter.fact(:cassandrarelease).value).to eql('3.0.1')
      expect(Facter.fact(:cassandramajorversion).value).to eql(3)
      expect(Facter.fact(:cassandraminorversion).value).to eql(0)
      expect(Facter.fact(:cassandrapatchversion).value).to eql(1)
    end
  end

  describe 'Cassandra not installed or not running' do
    it do
      allow(Facter::Util::Resolution)
        .to receive(:exec).with('nodetool version')
        .and_return('')
      expect(Facter.fact(:cassandrarelease).value).to eql(nil)
      expect(Facter.fact(:cassandramajorversion).value).to eql(nil)
      expect(Facter.fact(:cassandraminorversion).value).to eql(nil)
      expect(Facter.fact(:cassandrapatchversion).value).to eql(nil)
    end
  end
end
