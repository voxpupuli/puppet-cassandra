require 'spec_helper'

describe 'Facter::Util::Fact' do
  before do
    Facter.clear
  end

  describe 'cassandrarelease DSE' do
    it do
      allow(Facter::Util::Resolution).
        to receive(:exec).with('nodetool version').
        and_return('2.1.11.969')
    end

    it { expect(Facter.fact(:cassandrarelease).value).to eql('2.1.11') }
    it { expect(Facter.fact(:cassandramajorversion).value).to be(2) }
    it { expect(Facter.fact(:cassandraminorversion).value).to be(1) }
    it { expect(Facter.fact(:cassandrapatchversion).value).to be(11) }
  end

  describe 'cassandrarelease DDC' do
    it do
      allow(Facter::Util::Resolution).
        to receive(:exec).with('nodetool version').
        and_return('3.0.1')
    end

    it { expect(Facter.fact(:cassandrarelease).value).to eql('3.0.1') }
    it { expect(Facter.fact(:cassandramajorversion).value).to be(3) }
    it { expect(Facter.fact(:cassandraminorversion).value).to be(0) }
    it { expect(Facter.fact(:cassandrapatchversion).value).to be(1) }
  end

  describe 'Cassandra not installed or not running' do
    it do
      allow(Facter::Util::Resolution).
        to receive(:exec).with('nodetool version').
        and_return('')
    end

    it { expect(Facter.fact(:cassandrarelease).value).to be(nil) }
    it { expect(Facter.fact(:cassandramajorversion).value).to be(nil) }
    it { expect(Facter.fact(:cassandraminorversion).value).to be(nil) }
    it { expect(Facter.fact(:cassandrapatchversion).value).to be(nil) }
  end
end
