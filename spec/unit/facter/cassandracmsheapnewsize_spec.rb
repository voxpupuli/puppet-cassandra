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

  describe 'Heap settings' do
    context 'Rasberry Pi 3' do
      before :each do
        Facter.fact(:memorysize_mb).stubs(:value).returns('1024')
        Facter.fact(:processorcount).stubs(:value).returns('4')
      end

      it do
        expect(Facter.fact(:cassandramaxheapsize).value).to eq(512)
        expect(Facter.fact(:cassandracmsmaxheapsize).value).to eql(512)
        expect(Facter.fact(:cassandraheapnewsize).value).to eql(128)
        expect(Facter.fact(:cassandracmsheapnewsize).value).to eql(128)
      end
    end

    context 'm4.large' do
      before :each do
        Facter.fact(:memorysize_mb).stubs(:value).returns('8191.9')
        Facter.fact(:processorcount).stubs(:value).returns('2')
      end

      it do
        expect(Facter.fact(:cassandramaxheapsize).value).to eql(2048)
        expect(Facter.fact(:cassandracmsmaxheapsize).value).to eql(2048)
        expect(Facter.fact(:cassandraheapnewsize).value).to eql(200)
        expect(Facter.fact(:cassandracmsheapnewsize).value).to eql(200)
      end
    end

    context 'm4.xlarge' do
      before :each do
        Facter.fact(:memorysize_mb).stubs(:value).returns('16384')
        Facter.fact(:processorcount).stubs(:value).returns('2')
      end

      it do
        expect(Facter.fact(:cassandramaxheapsize).value).to eql(4096)
        expect(Facter.fact(:cassandracmsmaxheapsize).value).to eql(4096)
        expect(Facter.fact(:cassandraheapnewsize).value).to eql(200)
        expect(Facter.fact(:cassandracmsheapnewsize).value).to eql(200)
      end
    end

    context 'c4.2xlarge' do
      before :each do
        Facter.fact(:memorysize_mb).stubs(:value).returns('15360')
        Facter.fact(:processorcount).stubs(:value).returns('8')
      end

      it do
        expect(Facter.fact(:cassandramaxheapsize).value).to eql(3840)
        expect(Facter.fact(:cassandracmsmaxheapsize).value).to eql(3840)
        expect(Facter.fact(:cassandraheapnewsize).value).to eql(800)
        expect(Facter.fact(:cassandracmsheapnewsize).value).to eql(800)
      end
    end

    context 'i2.2xlarge' do
      before :each do
        Facter.fact(:memorysize_mb).stubs(:value).returns('62464')
        Facter.fact(:processorcount).stubs(:value).returns('8')
      end

      it do
        expect(Facter.fact(:cassandramaxheapsize).value).to eql(8192)
        expect(Facter.fact(:cassandracmsmaxheapsize).value).to eql(14_336)
        expect(Facter.fact(:cassandraheapnewsize).value).to eql(800)
        expect(Facter.fact(:cassandracmsheapnewsize).value).to eql(800)
      end
    end
  end
end
