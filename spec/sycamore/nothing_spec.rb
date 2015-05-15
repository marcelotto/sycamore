describe Sycamore::Nothing do

  Nothing = Sycamore::Nothing
  UnhandledNothingAccess = Sycamore::UnhandledNothingAccess

  it { is_expected.to be_a Singleton }
  it { is_expected.to be_a Sycamore::Tree }
  it { is_expected.to be_a Sycamore::NothingTree }

  describe 'query methods' do

    it { is_expected.to be_falsey }
    # it { is_expected.to be_nil }
    it { is_expected.to be_empty }

    describe '#size' do
      subject { Nothing.size }
      it { is_expected.to be 0 }
    end

    describe '#to_s' do
      subject { Nothing.to_s }
      it { is_expected.to eql '#<Sycamore::Nothing>' }
    end

    describe '#inspect' do
      subject { Nothing.inspect }
      it { is_expected.to eql '#<Sycamore::Nothing>' }
    end
  end


  describe 'command methods' do

    def expect_failing(&block)
      expect(&block).to raise_error UnhandledNothingAccess
    end

    it 'does raise an exception on all command methods' do
      expect_failing { Nothing << 'Bye' }
      expect_failing { Nothing.add 42 }
      expect_failing { Nothing.add_node 42 }
      expect_failing { Nothing.add_nodes :foo, :bar }
    end

    describe '#clear' do
      subject { Nothing.clear }
      it { is_expected.to be Nothing }

      it 'is the only command method that works' do
        expect { Nothing.clear }.not_to raise_error
      end

    end

  end

end
