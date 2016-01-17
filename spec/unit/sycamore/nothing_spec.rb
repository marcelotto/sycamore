describe Sycamore::Nothing do

  it { is_expected.to be_a Singleton }
  it { is_expected.to be_a Sycamore::Tree }

  it { is_expected.to be_falsey }

  describe 'query methods' do
    describe 'children' do
      specify { expect( Sycamore::Nothing.child_of(1) ).to be Sycamore::Nothing }
    end

    describe '#nothing?' do
      specify { expect( Sycamore::Nothing.nothing? ).to be true }
    end

    describe '#absent?' do
      specify { expect( Sycamore::Nothing.absent? ).to be true }
    end

    describe '#present?' do
      specify { expect( Sycamore::Nothing.present? ).to be false }
    end

    describe '#empty?' do
      specify { expect( Sycamore::Nothing.empty? ).to be true }
    end

    describe '#size' do
      specify { expect( Sycamore::Nothing.size ).to be 0 }
    end

    describe '#to_s' do
      specify { expect( Sycamore::Nothing.to_s ).to eql Sycamore::Tree[].to_s }
    end

    describe '#inspect' do
      specify { expect( Sycamore::Nothing.inspect ).to eql '#<Sycamore::Nothing>' }
    end
  end

  describe 'additive command methods' do
    it 'does raise an exception on all command methods' do
      expect_failing { Nothing << 'Bye' }
      expect_failing { Nothing.add 42 }
      expect_failing { Nothing.add :foo, :bar }
    end

    def expect_failing(&block)
      expect(&block)
    end
  end

  describe 'purely destructive command methods' do
    describe '#clear' do
      specify { expect( Sycamore::Nothing.clear ).to be Sycamore::Nothing }
    end

    describe '#delete' do
      specify { expect( Sycamore::Nothing >> :foo    ).to be Sycamore::Nothing }
      specify { expect( Sycamore::Nothing.delete(42) ).to be Sycamore::Nothing }
    end
  end

end
