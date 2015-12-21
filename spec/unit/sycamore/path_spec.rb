describe Sycamore::Path do

  it 'can not be created via new' do
    expect { Sycamore::Path.new(:foo, :bar) }.to raise_error NoMethodError
  end

  ############################################################################

  describe '.root' do
    subject(:root) { Sycamore::Path.root }
    it { is_expected.to be_a Sycamore::Path }
    it { is_expected.to be   Sycamore::Path.root }
    it { is_expected.to be   Sycamore::Path::ROOT }
  end

  ############################################################################


  describe '.of' do

    context 'when given no arguments' do
      specify { expect( Sycamore::Path[] ).to be Sycamore::Path.root }
    end

    context 'when given nil' do
      specify { expect { Sycamore::Path[nil] }.to raise_error IndexError }
    end

    context 'when given a single node only' do
      specify { expect( Sycamore::Path[ 42  ] ).to be_path_of 42    }
      specify { expect( Sycamore::Path[:foo ] ).to be_path_of :foo  }
      specify { expect( Sycamore::Path['bar'] ).to be_path_of 'bar' }
    end

    context 'when given a collection of nodes only' do

      context 'when the collection contains nil values' do
        specify { expect { Sycamore::Path[1, nil, 3] }.to raise_error IndexError }
      end

      context 'when the collection is given as multiple arguments' do
        let(:nodes) { [1, 2, 3] }
        subject(:branch) { Sycamore::Path.of(*nodes) }
        it { is_expected.to be_path_of *nodes }
      end

      context 'when the collection is given as a single Enumerable' do
        let(:nodes) { [1, 2, 3] }
        subject(:branch) { Sycamore::Path.of(nodes) }
        it { is_expected.to be_path_of *nodes }
      end

    end

    context 'when given a Path only' do
      describe 'given [1, 2, 3]' do
        let(:given_path) { Sycamore::Path[1, 2, 3] }
        subject { Sycamore::Path[given_path] }
        it { is_expected.to be given_path }
      end
    end

    context 'when given a Path and a single node' do
      describe 'given [1, 2, 3] and 4' do
        let(:given_path) { Sycamore::Path[1, 2, 3] }
        let(:given_node) { 4 }
        subject(:path) { Sycamore::Path[given_path, given_node] }
        specify { expect(path.node).to be given_node }
        specify { expect(path.parent).to be given_path }
      end

    end

    context 'when given a Path and a collection of nodes' do
      context 'when the collection of nodes is given as an Enumerable' do
        pending
      end

      context 'when the collection of nodes is given as multiple args' do
        pending
      end
    end


  end


  ############################################################################

  describe '#root?' do
    it { expect( Sycamore::Path[].root? ).to be true }
    it { expect( Sycamore::Path[42].root? ).to be false }
  end

  ############################################################################

  describe '#length' do
    specify { expect( Sycamore::Path[].length).to be 0 }
    specify { expect( Sycamore::Path[42].length).to be 1 }
    specify { expect( Sycamore::Path.of([1,2,3]).length).to be 3 }
  end

  ############################################################################

  describe '#up' do
    pending
  end

  ############################################################################

  describe '#branch' do
    pending 'see Path::Root#branch ; shared_examples ...?'
  end

  # describe '#[]' # as alias of 'branch'
  # describe '#+' # as alias of 'branch'
  # describe '#/' # as alias of 'branch'
  # describe '#join' # same as #+ or similar difference as in Rubys Pathname lib?


  ############################################################################

  describe '#each_node' do
    specify { expect { |b| Sycamore::Path[1,2,3].each(&b) }.to yield_successive_args 1,2,3 }
    specify { expect( Sycamore::Path[1,2,3].each ).to be_a Enumerator }
    specify { expect( Sycamore::Path[1,2,3].each.to_a ).to eq [1,2,3] }
  end

  ############################################################################

  describe '#present_in?' do
    context 'when given a Hash' do
      specify { expect( Sycamore::Path[1    ].in?({1=>2}) ).to be true }
      specify { expect( Sycamore::Path[1,2  ].in?({1=>2}) ).to be true }
      specify { expect( Sycamore::Path[1,2,3].in?({1=>2}) ).to be false }
      specify { expect( Sycamore::Path[1,2,3].in?({1=>{2=>3}}) ).to be true }
      specify { expect( Sycamore::Path[2    ].in?({1=>2}) ).to be false }
      specify { pending "Can/should we support this?" ; expect( Sycamore::Path[1,2  ].in?({1=>[2,3]}) ).to be true }
    end

    context 'when given a Tree' do
      specify { expect( Sycamore::Path[1    ].in? Sycamore::Tree[1=>2] ).to be true }
      specify { expect( Sycamore::Path[1,2  ].in? Sycamore::Tree[1=>2] ).to be true }
      specify { expect( Sycamore::Path[1,2,3].in? Sycamore::Tree[1=>2] ).to be false }
      specify { expect( Sycamore::Path[1,2,3].in? Sycamore::Tree[1=>{2=>3}] ).to be true }
      specify { expect( Sycamore::Path[2    ].in? Sycamore::Tree[1=>2] ).to be false }
      specify { expect( Sycamore::Path[1,2  ].in? Sycamore::Tree[1=>[2,3]] ).to be true }
    end
  end

  ############################################################################

  describe '#fetch_from' do
    context 'when given a Tree'
    context 'when given a Hash'
  end


  ################################################################
  # equality and equivalence                                     #
  ################################################################

  describe '#==' do
    specify { expect( Sycamore::Path[     ] ).to     eq Sycamore::Path[] }
    specify { expect( Sycamore::Path[1    ] ).not_to eq Sycamore::Path[2] }
    specify { expect( Sycamore::Path[1    ] ).to     eq Sycamore::Path[1] }
    specify { expect( Sycamore::Path[1    ] ).to     eq [1] }
    specify { expect( Sycamore::Path[1,2,3] ).to     eq Sycamore::Path[1,2,3] }
    specify { expect( Sycamore::Path[1,2,3] ).to     eq [1,2,3] }
    specify { expect( Sycamore::Path[1,2,3] ).not_to eq Sycamore::Path[3,2,1] }
  end

  ############################################################################

  describe '#===' do  # matches Enumerables, supports non-terminals for matchers ...
    pending
  end

  ############################################################################

  describe '#eql?' do
    specify { expect( Sycamore::Path[     ] ).to     eql Sycamore::Path[] }
    specify { expect( Sycamore::Path[1    ] ).not_to eql Sycamore::Path[2] }
    specify { expect( Sycamore::Path[1    ] ).to     eql Sycamore::Path[1] }
    specify { expect( Sycamore::Path[1    ] ).not_to eql [1] }
    specify { expect( Sycamore::Path[1,2,3] ).to     eql Sycamore::Path[1,2,3] }
    specify { expect( Sycamore::Path[1,2,3] ).not_to eql Sycamore::Path[3,2,1] }
  end

  ############################################################################

  describe '#hash' do
    pending
    specify { expect( Sycamore::Path[].hash      == Sycamore::Path[].hash      ).to be true }
    specify { expect( Sycamore::Path[1].hash     == Sycamore::Path[1].hash     ).to be true }
    specify { expect( Sycamore::Path[1].hash     == Sycamore::Path[2].hash     ).to be false }
    specify { expect( Sycamore::Path[1,2,3].hash == Sycamore::Path[1,2,3].hash ).to be true }
    specify { expect( Sycamore::Path[1,2,3].hash == Sycamore::Path[3,2,1].hash ).to be false }

    specify { expect( Sycamore::Path[].hash      == Array.new.hash   ).to be false }
    specify { expect( Sycamore::Path[1,2,3].hash == Array[1,2,3].hash).to be false }
  end


  ################################################################
  # conversion                                                   #
  ################################################################

  describe '#to_a' do
    specify { expect( Sycamore::Path[ 42             ].to_a ).to eq [42] }
    specify { expect( Sycamore::Path[ 1, 2, 3        ].to_a ).to eq [1,2,3] }
    specify { expect( Sycamore::Path['foo'           ].to_a ).to eq ["foo"] }
    specify { expect( Sycamore::Path['foo', 'bar'    ].to_a ).to eq %w[foo bar] }
    specify { expect( Sycamore::Path['foo', 'bar', 42].to_a ).to eq ['foo', 'bar', 42] }
  end

  ############################################################################

  describe '#to_s' do
    specify { expect( Sycamore::Path[ 42             ].to_s ).to eq "42" }
    specify { expect( Sycamore::Path[ 1, 2, 3        ].to_s ).to eq "1/2/3" }
    specify { expect( Sycamore::Path['foo'           ].to_s ).to eq "foo" }
    specify { expect( Sycamore::Path['foo', 'bar'    ].to_s ).to eq "foo/bar" }
    specify { expect( Sycamore::Path['foo', 'bar', 42].to_s ).to eq "foo/bar/42" }

    # This way?
    specify { expect( Sycamore::Path[:foo].to_s ).to eq "foo" }
    specify { expect( Sycamore::Path[:foo, :bar].to_s ).to eq "foo/bar" }
    specify { expect( Sycamore::Path['foo', :bar].to_s ).to eq "foo/bar" }

    # Or that way?
    # specify { expect( Sycamore::Path[:foo].to_s ).to eq ":foo" }
    # specify { expect( Sycamore::Path[:foo, :bar].to_s ).to eq ":foo/:bar" }
    # specify { expect( Sycamore::Path['foo', :bar].to_s ).to eq "foo/:bar" }

  end

  ############################################################################

  describe '#inspect' do
    shared_examples_for 'every inspect string' do |path|
      it 'is in the usual Ruby inspect style' do
        expect( path.inspect ).to match /^#<Sycamore::Path/
      end
      it 'contains the string representation/serialization' do
        path.each_node { |node| expect( path.inspect ).to include node.inspect }
      end
    end

    include_examples 'every inspect string', Sycamore::Path[1,2,3]
    include_examples 'every inspect string', Sycamore::Path['foo', 'bar']
  end

end
