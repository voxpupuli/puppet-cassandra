# frozen_string_literal: true

require 'spec_helper'

describe 'cassandrarelease' do
  before { Facter.clear }

  after { Facter.clear }

  describe 'cassandrarelease DSE' do
    it do
      Facter::Util::Resolution.stubs(:exec).with('nodetool version').returns('2.1.11.969')
      expect(Facter.fact(:cassandrarelease).value).to eql('2.1.11')
    end
  end

  describe 'cassandrarelease DDC' do
    it do
      Facter::Util::Resolution.stubs(:exec).with('nodetool version').returns('3.0.1')
      expect(Facter.fact(:cassandrarelease).value).to eql('3.0.1')
    end
  end

  describe 'Cassandra not installed or not running' do
    it do
      Facter::Util::Resolution.stubs(:exec).with('nodetool version').returns('')
      expect(Facter.fact(:cassandrarelease).value).to be_nil
    end
  end
end
