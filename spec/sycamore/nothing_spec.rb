describe Sycamore::Nothing do

  Nothing = Sycamore::Nothing
  UnhandledNothingAccess = Sycamore::UnhandledNothingAccess

  it { is_expected.to be_a Singleton }
  it { is_expected.to be_a Sycamore::Tree }
  it { is_expected.to be_a Sycamore::NothingTree }

  describe 'falsiness' do
    it { is_expected.to be_falsey }
    # it { is_expected.to be_nil }
  end

  describe 'query methods' do

    describe '#nothing?' do
      it { is_expected.to be_nothing }
    end

    describe '#present? and #absent?' do
      it { is_expected.not_to be_present }
      it { is_expected.to be_absent }
    end

    describe '#empty?' do
      it { is_expected.to be_empty }
    end

    describe '#size' do
      it { expect( Nothing.size ).to be 0 }
    end

    describe '#to_s' do
      it { expect( Nothing.to_s ).to eql '#<Sycamore::Nothing>' }
    end

    describe '#inspect' do
      it { expect( Nothing.inspect ).to eql '#<Sycamore::Nothing>' }
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
