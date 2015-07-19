describe Sycamore::Path::ROOT do
  subject(:root) { Sycamore::Path::ROOT }

  it { is_expected.to be_a Sycamore::Path }
  it { is_expected.to be_root }

  describe '#node' do
    subject { root.node }
    it { is_expected.to be :root }
  end

  describe '#parent' do
    subject { root.parent }
    it { is_expected.to be_nil }
  end

  describe '#root?' do
    it { expect( root.root? ).to be true }
  end

  describe '#length' do
    specify { expect( root.length ).to be 0 }
  end

  describe '#up' do
    specify { expect( root.up ).to be root }
    specify { expect( root.up(3) ).to be root }
  end

  describe '#branch' do

    context 'when given a single node' do
      subject(:branch) { root.branch 42 }
      it { is_expected.to be_path_of 42 }
    end

    context 'when given a collection of nodes' do

      context 'when the collection contains nil values' do
        specify { expect { Sycamore::Path[1, nil, 3] }.to raise_error IndexError }
      end

      context 'when the collection is given as multiple arguments' do
        let(:nodes) { [1, 2, 3] }
        subject(:branch) { root.branch(*nodes) }
        it { is_expected.to be_path_of *nodes }
      end

      context 'when the collection is given as a single Enumerable' do
        let(:nodes) { [1, 2, 3] }
        subject(:branch) { root.branch(nodes) }
        it { is_expected.to be_path_of *nodes }
      end

    end

  end

  describe '#to_s' do
    specify { expect( root.to_s ).to eq "#<Sycamore::Path::Root>" }
  end

  describe '#inspect' do
    specify { expect( root.inspect ).to eq "#<Sycamore::Path::Root>" }
  end

end
