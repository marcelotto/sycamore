describe Sycamore::Path::ROOT do
  subject(:root) { Sycamore::Path::ROOT }

  it { is_expected.to be_a Sycamore::Path }

  ############################################################################

  describe '#node' do
    specify { expect( root.node ).to be_nil }
  end

  ############################################################################

  describe '#parent' do
    specify { expect( root.parent ).to be_nil }
  end

  ############################################################################

  describe '#up' do
    it 'does return the root tree again, for any given distance' do
      expect( root.up ).to be root
      expect( root.up(3) ).to be root
    end

    it 'does raise an error, if not given an integer' do
      expect { root.up(nil) }.to raise_error TypeError
      expect { root.up('1') }.to raise_error TypeError
      expect { root.up(1.1) }.to raise_error TypeError
    end
  end

  ############################################################################

  describe '#root?' do
    specify { expect( root.root? ).to be true }
  end

  ############################################################################

  describe '#length' do
    specify { expect( root.length ).to be 0 }
  end

  ############################################################################

  describe '#present_in?' do
    it 'does always return true' do
      expect( root.in? 1 ).to be true
      expect( root.in? nil ).to be true
    end
  end

  ############################################################################

  describe '#to_s' do
    specify { expect( root.to_s ).to eq "#<Path:Root>" }
  end

  ############################################################################

  describe '#inspect' do
    specify { expect( root.inspect ).to eq "#<Sycamore::Path::Root>" }
  end

end
