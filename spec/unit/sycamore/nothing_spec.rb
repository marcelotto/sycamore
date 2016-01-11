describe Sycamore::Nothing do

  Nothing = Sycamore::Nothing
  UnhandledNothingAccess = Sycamore::UnhandledNothingAccess

  it { is_expected.to be_a Singleton }
  it { is_expected.to be_a Sycamore::Tree }
  it { is_expected.to be_a Sycamore::NothingTree }

  describe 'falsiness' do
    it { is_expected.to be_falsey }
  end

  describe 'query methods' do
    describe '#nothing?' do
      specify { expect( Nothing.nothing? ).to be true }
    end

    describe '#present?' do
      specify { expect( Nothing.present? ).to be false }
    end

    describe '#absent?' do
      specify { expect( Nothing.absent? ).to be true }
    end

    describe '#empty?' do
      specify { expect( Nothing.empty? ).to be true }
    end

    describe '#size' do
      specify { expect( Nothing.size ).to be 0 }
    end

    describe '#to_s' do
      specify { expect( Nothing.to_s ).to eql Sycamore::Tree[].to_s }
    end

    describe '#inspect' do
      specify { expect( Nothing.inspect ).to eql '#<Sycamore::Nothing>' }
    end
  end


  describe 'command methods' do

    def expect_failing(&block)
      expect(&block).to raise_error UnhandledNothingAccess
    end

    it 'does raise an exception on all command methods' do
      expect_failing { Nothing << 'Bye' }
      expect_failing { Nothing.add 42 }
      expect_failing { Nothing.add :foo, :bar }
    end

    describe '#clear' do
      subject { Nothing.clear }
      it { is_expected.to be Nothing }

      it 'does not raise an error' do
        expect { Nothing.clear }.not_to raise_error
      end
    end

    describe '#remove' do
      subject { pending 'Tree#remove' ; Nothing.remove(1) }
      it { is_expected.to be Nothing }

      it 'does not raise an error' do
        pending 'Tree#remove'
        expect { Nothing.remove(1) }.not_to raise_error
      end

    end

  end

end
