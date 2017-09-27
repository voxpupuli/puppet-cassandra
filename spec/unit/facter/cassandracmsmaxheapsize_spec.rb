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

  describe 'Heap settings' do
    context 'Rasberry Pi 3' do
      before do
        Facter.fact(:memorysize_mb).stubs(:value).returns('1024')
        Facter.fact(:processorcount).stubs(:value).returns('4')
      end

      it { expect(Facter.fact(:cassandramaxheapsize).value).to eq(512) }
      it { expect(Facter.fact(:cassandracmsmaxheapsize).value).to be(512) }
      it { expect(Facter.fact(:cassandraheapnewsize).value).to be(128) }
      it { expect(Facter.fact(:cassandracmsheapnewsize).value).to be(128) }
    end

    context 'm4.large' do
      before do
        Facter.fact(:memorysize_mb).stubs(:value).returns('8191.9')
        Facter.fact(:processorcount).stubs(:value).returns('2')
      end

      it { expect(Facter.fact(:cassandramaxheapsize).value).to be(2048) }
      it { expect(Facter.fact(:cassandracmsmaxheapsize).value).to be(2048) }
      it { expect(Facter.fact(:cassandraheapnewsize).value).to be(200) }
      it { expect(Facter.fact(:cassandracmsheapnewsize).value).to be(200) }
    end

    context 'm4.xlarge' do
      before do
        Facter.fact(:memorysize_mb).stubs(:value).returns('16384')
        Facter.fact(:processorcount).stubs(:value).returns('2')
      end

      it { expect(Facter.fact(:cassandramaxheapsize).value).to be(4096) }
      it { expect(Facter.fact(:cassandracmsmaxheapsize).value).to be(4096) }
      it { expect(Facter.fact(:cassandraheapnewsize).value).to be(200) }
      it { expect(Facter.fact(:cassandracmsheapnewsize).value).to be(200) }
    end

    context 'c4.2xlarge' do
      before do
        Facter.fact(:memorysize_mb).stubs(:value).returns('15360')
        Facter.fact(:processorcount).stubs(:value).returns('8')
      end

      it { expect(Facter.fact(:cassandramaxheapsize).value).to be(3840) }
      it { expect(Facter.fact(:cassandracmsmaxheapsize).value).to be(3840) }
      it { expect(Facter.fact(:cassandraheapnewsize).value).to be(800) }
      it { expect(Facter.fact(:cassandracmsheapnewsize).value).to be(800) }
    end

    context 'i2.2xlarge' do
      before do
        Facter.fact(:memorysize_mb).stubs(:value).returns('62464')
        Facter.fact(:processorcount).stubs(:value).returns('8')
      end

      it { expect(Facter.fact(:cassandramaxheapsize).value).to be(8192) }
      it { expect(Facter.fact(:cassandracmsmaxheapsize).value).to be(14_336) }
      it { expect(Facter.fact(:cassandraheapnewsize).value).to be(800) }
      it { expect(Facter.fact(:cassandracmsheapnewsize).value).to be(800) }
    end
  end
end
