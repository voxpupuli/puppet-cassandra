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

      it { expect(Facter.fact(:cassandraheapnewsize).value).to be(128) }
    end

    context 'm4.large' do
      before do
        Facter.fact(:memorysize_mb).stubs(:value).returns('8191.9')
        Facter.add(:processorcount) { setcode { '2' } }
      end

      it { expect(Facter.fact(:cassandraheapnewsize).value).to be(200) }
    end

    context 'm4.xlarge' do
      before do
        Facter.fact(:memorysize_mb).stubs(:value).returns('16384')
        Facter.add(:processorcount) { setcode { '2' } }
      end

      it { expect(Facter.fact(:cassandraheapnewsize).value).to be(200) }
    end

    context 'c4.2xlarge' do
      before do
        Facter.fact(:memorysize_mb).stubs(:value).returns('15360')
        if Facter.fact(:processorcount).value.nil?
          Facter.add(:processorcount) { setcode { '8' } }
        else
          Facter.fact(:processorcount).stubs(:value).returns('8')
        end
      end

      it { expect(Facter.fact(:cassandraheapnewsize).value).to be(800) } # BROKEN in CI
    end

    context 'i2.2xlarge' do
      before do
        Facter.fact(:memorysize_mb).stubs(:value).returns('62464')
        if Facter.fact(:processorcount).value.nil?
          Facter.add(:processorcount) { setcode { '8' } }
        else
          Facter.fact(:processorcount).stubs(:value).returns('8')
        end
      end

      it { expect(Facter.fact(:cassandraheapnewsize).value).to be(800) } # BROKEN in CI
    end
  end
end
