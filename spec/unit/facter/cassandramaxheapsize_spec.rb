require 'spec_helper'

describe Facter::Util::Fact do
  before { Facter.clear }
  after { Facter.clear }

  describe 'Heap settings' do
    context 'Rasberry Pi 3' do
      before do
        Facter.fact(:memorysize_mb).stubs(:value).returns('1024')
        Facter.add(:processorcount) { setcode { '4' } }
      end

      it { expect(Facter.fact(:cassandramaxheapsize).value).to eq(512) }
    end

    context 'm4.large' do
      before do
        Facter.fact(:memorysize_mb).stubs(:value).returns('8191.9')
        Facter.add(:processorcount) { setcode { '2' } }
      end

      it { expect(Facter.fact(:cassandramaxheapsize).value).to be(2048) }
    end

    context 'm4.xlarge' do
      before do
        Facter.fact(:memorysize_mb).stubs(:value).returns('16384')
        Facter.add(:processorcount) { setcode { '2' } }
      end

      it { expect(Facter.fact(:cassandramaxheapsize).value).to be(4096) }
    end

    context 'c4.2xlarge' do
      before do
        Facter.fact(:memorysize_mb).stubs(:value).returns('15360')
        Facter.add(:processorcount) { setcode { '8' } }
      end

      it { expect(Facter.fact(:cassandramaxheapsize).value).to be(3840) }
    end

    context 'i2.2xlarge' do
      before do
        Facter.fact(:memorysize_mb).stubs(:value).returns('62464')
        Facter.add(:processorcount) { setcode { '8' } }
      end

      it { expect(Facter.fact(:cassandramaxheapsize).value).to be(8192) }
    end
  end
end
