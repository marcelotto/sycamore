describe Sycamore::Path do

  let(:example_path) { Sycamore::Path[:foo, :bar] }

  ############################################################################
  # Construction
  ############################################################################

  describe '.new' do
    it 'is not available' do
      expect { Sycamore::Path.new(:foo, :bar) }.to raise_error NoMethodError
    end
  end

  ############################################################################

  describe '.root' do
    it 'does return the Path::ROOT singleton' do
      expect( Sycamore::Path.root ).to be Sycamore::Path::ROOT
    end
  end

  ############################################################################

  describe '.of' do
    context 'when the first argument is a path' do
      it 'does delegate to the branch method of the given path with the rest of the arguments' do
        path = Sycamore::Path[:foo]
        expect( path ).to receive(:branch).with(:bar)
        Sycamore::Path.of(path, :bar)
      end
    end

    context 'when the first argument is not a path' do
      it 'does delegate to the branch method of the root path with the given arguments' do
        expect( Sycamore::Path.root ).to receive(:branch).with(1, 2)
        Sycamore::Path.of(1, 2)
      end
    end

    it 'does return the root path, when no arguments given' do
      expect( Sycamore::Path[] ).to be Sycamore::Path.root
    end

    context 'edge cases' do
      it 'does raise an error, when given a nested collection' do
        expect { Sycamore::Path[1, [2], 3] }.to raise_error Sycamore::InvalidNode
        expect { Sycamore::Path[:foo, {bar: :baz}] }.to raise_error Sycamore::InvalidNode
      end
    end
  end

  ############################################################################
  # Element access
  ############################################################################

  describe '#node' do
    it 'does return the last node of a path' do
      expect( Sycamore::Path[1].node ).to be 1
      expect( Sycamore::Path[:foo, :bar].node ).to be :bar
    end
  end

  ############################################################################

  describe '#parent' do
    it 'does return the path without the last node' do
      expect( Sycamore::Path[1].parent ).to be Sycamore::Path.root
      expect( Sycamore::Path[:foo, :bar].parent ).to eq Sycamore::Path[:foo]
    end
  end

  ############################################################################

  describe '#branch' do
    context 'when no arguments given' do
      it 'does return the path itself' do
        path = Sycamore::Path[]
        expect( path.branch() ).to be path

        path = Sycamore::Path[1, 2, 3]
        expect( path.branch() ).to be path
      end
    end

    context 'when given a single node' do
      it 'does return a path with given node appended' do
        expect( Sycamore::Path[ ].branch(1)).to be_path_of 1
        expect( Sycamore::Path[1].branch(2)).to be_path_of 1, 2
      end
    end

    context 'when given multiple arguments' do
      it 'does return a path with the given nodes appended' do
        expect( Sycamore::Path[ ].branch(:foo, :bar)).to be_path_of :foo, :bar
        expect( Sycamore::Path[1].branch(2, 3)).to be_path_of 1, 2, 3
      end
    end

    context 'when given a collection of nodes' do
      it 'does return a path with the given nodes appended' do
        expect( Sycamore::Path[ ].branch([:foo, :bar])).to be_path_of :foo, :bar
        expect( Sycamore::Path[1].branch([2, 3])).to be_path_of 1, 2, 3
      end
    end

    context 'when given another Path' do
      it 'does return a path with the nodes of the given path appended' do
        another_path = Sycamore::Path[2, 3]
        expect( Sycamore::Path[ ].branch(another_path)).to be_path_of 2, 3
        expect( Sycamore::Path[1].branch(another_path)).to be_path_of 1, 2, 3
      end
    end

    context 'edge cases' do
      it 'does treat nil like any other value' do
        expect( Sycamore::Path[1].branch(nil)    ).to be_path_of 1, nil
        expect( Sycamore::Path[1].branch(nil, 2) ).to be_path_of 1, nil, 2
        expect( Sycamore::Path[1].branch(2, nil) ).to be_path_of 1, 2, nil
      end

      it 'does raise an error, when given multiple collections of nodes' do
        expect { Sycamore::Path[1].branch([:foo, :bar], [:baz]) }.to raise_error Sycamore::InvalidNode
      end

      it 'does raise an error, when given a nested collection' do
        expect { Sycamore::Path[1].branch([1, [2], 3]) }.to raise_error Sycamore::InvalidNode
        expect { Sycamore::Path[1].branch([:foo, {bar: :baz}]) }.to raise_error Sycamore::InvalidNode
      end

      it 'does raise an error, when given a nested collection' do
        expect { Sycamore::Path[1].branch([1, [2], 3]) }.to raise_error Sycamore::InvalidNode
        expect { Sycamore::Path[1].branch([:foo, {bar: :baz}]) }.to raise_error Sycamore::InvalidNode
        expect { Sycamore::Path[1].branch(Sycamore::Path[2, 3], 4) }.to raise_error Sycamore::InvalidNode
        expect { Sycamore::Path[1].branch(2, Sycamore::Path[3, 4]) }.to raise_error Sycamore::InvalidNode
        expect { Sycamore::Path[1].branch(Sycamore::Path[2, 3], Sycamore::Path[4, 5]) }.to raise_error Sycamore::InvalidNode
      end
    end
  end

  ############################################################################

  describe '#up' do
    it 'does return the path itself, when the given distance is 0' do
      path = Sycamore::Path[1, 2, 3]
      expect( path.up(0) ).to be path
    end

    it 'does return the parent, when the given distance is 1 or not specified ' do
      path = Sycamore::Path[1, 2, 3]
      expect( path.up ).to be path.parent
    end

    it 'does return the path above the given distance' do
      path = Sycamore::Path[1, 2, 3]
      expect( path.up(1) ).to be path.parent
      expect( path.up(2) ).to be path.parent.parent
      expect( path.up(3) ).to be path.parent.parent.parent
    end

    it 'does raise an error, if not given an integer' do
      expect { Sycamore::Path[1,2,3].up(nil) }.to raise_error TypeError
      expect { Sycamore::Path[1,2,3].up('1') }.to raise_error TypeError
      expect { Sycamore::Path[1,2,3].up(1.1) }.to raise_error TypeError
    end
  end

  ############################################################################

  describe '#[]' do
    it 'does return the node at the given index position if present' do
      expect( example_path[0] ).to be :foo
      expect( example_path[1] ).to be :bar
    end

    it 'does return nil if the given index is out of range' do
      expect( example_path[2] ).to be_nil
    end
  end

  ############################################################################

  describe '#fetch' do
    it 'does return the node at the given index position if present' do
      expect( example_path.fetch(0) ).to be :foo
      expect( example_path.fetch(1) ).to be :bar
    end

    it 'does raise an error if the given index is out of range' do
      expect { example_path.fetch(2) }.to raise_error IndexError
    end
  end

  ############################################################################

  describe '#root?' do
    specify { expect( example_path.root? ).to be false }
  end

  ############################################################################

  describe '#length' do
    it 'does return the number of nodes on this path' do
      expect( Sycamore::Path[     ].length).to be 0
      expect( Sycamore::Path[42   ].length).to be 1
      expect( Sycamore::Path[1,2,3].length).to be 3
    end
  end

  ############################################################################

  describe '#each_node' do
    it 'does yield the block with each node of the path as an argument' do
      expect { |b| Sycamore::Path[1,2,3].each(&b) }.to yield_successive_args 1,2,3
    end

    context 'when no block given' do
      it 'does return an enumerator' do
        expect( Sycamore::Path[1,2,3].each_node ).to be_a Enumerator
      end

      it 'does return an enumerator over the nodes' do
        expect( Sycamore::Path[1,2,3].each_node.to_a ).to eq [1,2,3]
      end
    end
  end

  ############################################################################

  describe '#present_in?' do
    PRESENT_IN_EXAMPLES = [
      # Path    , Structure
      [ [1]     , 1 ],
      [ [1]     , [1] ],
      [ [1, 2]  , {1 => 2} ],
      [ [1]     , {1 => {2 => 3, 4 => 5}} ],
      [ [1,2]   , {1 => {2 => 3, 4 => 5}} ],
      [ [1,2,3] , {1 => {2 => 3, 4 => 5}} ],
      [ [1,2]   , {1 => [2, 3]} ],
      [ [1,2,3] , {1 => {2 => [3], 4 => 5}} ],
    ]
    NOT_PRESENT_IN_EXAMPLES = [
      [ [1]     , {} ],
      [ [1]     , [] ],
      [ [2]     , {1 => 2} ],
      [ [1,2,3] , {1 => 2} ],
    ]

    context 'when given a structure' do
      it 'does return true, if the given structure includes this path' do
        PRESENT_IN_EXAMPLES.each do |path_nodes, struct|
          path = Sycamore::Path[*path_nodes]
          expect( path.in?(struct) ).to be(true),
            "expected #{struct.inspect} to include path #{path.inspect}"
        end
      end

      it 'does return false, if the given structure does not include this path' do
        NOT_PRESENT_IN_EXAMPLES.each do |path_nodes, struct|
          path = Sycamore::Path[*path_nodes]
          expect( path.in?(struct) ).to be(false),
            "expected #{struct.inspect} not to include path #{path.inspect}"
        end
      end
    end

    context 'when given a Tree' do
      it 'does return true, if the given tree includes this path' do
        PRESENT_IN_EXAMPLES.each do |path_nodes, struct|
          path, tree = Sycamore::Path[*path_nodes], Sycamore::Tree[struct]
          expect( path.in?(tree) ).to be(true),
            "expected #{tree.inspect} to include path #{path.inspect}"
        end
      end

      it 'does return false, if the given tree does not include this path' do
        NOT_PRESENT_IN_EXAMPLES.each do |path_nodes, struct|
          path, tree = Sycamore::Path[*path_nodes], Sycamore::Tree[struct]
          expect( path.in?(tree) ).to be(false),
            "expected #{tree.inspect} not to include path #{path.inspect}"
        end
      end
    end

    context 'edge cases' do
      it 'does treat nil like any other value' do
        expect( Sycamore::Path[nil].in? nil ).to be true
        expect( Sycamore::Path[nil].in? [nil, :foo] ).to be true
        expect( Sycamore::Path[nil, 1].in? nil => 1 ).to be true
        expect( Sycamore::Path[nil, nil].in? nil => [nil] ).to be true
      end
    end
  end

  ############################################################################
  # Equality
  ############################################################################

  PATH_EQL = [
    [ Sycamore::Path[     ] , Sycamore::Path[] ],
    [ Sycamore::Path[1    ] , Sycamore::Path[1] ],
    [ Sycamore::Path[nil  ] , Sycamore::Path[nil] ],
    [ Sycamore::Path[1,2,3] , Sycamore::Path[1,2,3] ],
    [ Sycamore::Path[nil, nil] , Sycamore::Path[nil, nil] ],
  ]

  PATH_EQ = PATH_EQL + [
    [ Sycamore::Path[]        , [] ],
    [ Sycamore::Path[1, 2, 3] , [1, 2, 3] ],
    [ Sycamore::Path[1, 2.0]  , [1.0, 2] ],
  ]

  PATH_NOT_EQ_BY_CONTENT = [
    [ Sycamore::Path[1]     , Sycamore::Path[2] ],
    [ Sycamore::Path[/a/]   , Sycamore::Path['a'] ],
    [ Sycamore::Path[1,2,3] , Sycamore::Path[1,2] ],
    [ Sycamore::Path[1,2]   , Sycamore::Path[1,2,3] ],
  ]

  PATH_NOT_EQL_BY_CONTENT = PATH_NOT_EQ_BY_CONTENT + [
    [ Sycamore::Path[1]     , Sycamore::Path[1.0] ],
  ]

  PATH_NOT_EQL_BY_ORDER = [
    [ Sycamore::Path[1,2,3] , Sycamore::Path[3,2,1] ],
  ]

  PATH_NOT_EQL_BY_TYPE = [
    [ Sycamore::Path[]      , [] ],
    [ Sycamore::Path[1,2,3] , [1,2,3] ],
  ]

  PATH_NOT_EQL = PATH_NOT_EQL_BY_TYPE + PATH_NOT_EQL_BY_CONTENT + PATH_NOT_EQL_BY_ORDER

  ############################################################################

  describe '#eql?' do
    it 'does return true, when the other is of the same type and has eql content' do
      PATH_EQL.each do |path, other|
        expect(path).to eql(other)
      end
    end

    it 'does return false, when the content is not eql' do
      PATH_NOT_EQL_BY_CONTENT.each do |path, other|
        expect(path).not_to eql(other)
      end
    end

    it 'does return false, when the order is not equal' do
      PATH_NOT_EQL_BY_ORDER.each do |path, other|
        expect(path).not_to eql(other)
      end
    end

    it 'does return false, when the type is not equal' do
      PATH_NOT_EQL_BY_TYPE.each do |path, other|
        expect(path).not_to eql(other)
      end
    end
  end

  ############################################################################

  describe '#hash' do
    it 'does produce equal values, when the path is eql' do
      PATH_EQL.each do |path, other|
        expect( path.hash ).to be(other.hash),
          "expected the hash of #{path.inspect} to be also the hash of #{other.inspect}"
      end
    end

    it 'does produce different values, when the path is not eql' do
      PATH_NOT_EQL.each do |path, other|
        expect(path.hash).not_to eq(other.hash),
          "expected the hash of #{path.inspect} not to equal the hash of #{other.inspect}"
      end
    end
  end

  ############################################################################

  describe '#==' do
    it 'does return true, when the other is an enumerable, has == nodes in the same order' do
      PATH_EQ.each do |path, other|
        expect(path).to eq(other)
      end
    end

    it 'does return false, when the content is not ==' do
      PATH_NOT_EQ_BY_CONTENT.each do |path, other|
        expect(path).not_to eq(other)
      end
    end

    it 'does return false, when the order is not equal' do
      PATH_NOT_EQL_BY_ORDER.each do |path, other|
        expect(path).not_to eq(other)
      end
    end

    it 'does return false, when the other is not an enumerable' do
      expect( Sycamore::Path[1] ).not_to eq 1
    end
  end

  ############################################################################
  # Conversion
  ############################################################################

  describe '#to_a' do
    it 'does return an array representation of the path' do
      expect( Sycamore::Path[ 42             ].to_a ).to eq [42]
      expect( Sycamore::Path[ nil            ].to_a ).to eq [nil]
      expect( Sycamore::Path[ 1, 2, 3        ].to_a ).to eq [1,2,3]
      expect( Sycamore::Path['foo'           ].to_a ).to eq ["foo"]
      expect( Sycamore::Path['foo', 'bar'    ].to_a ).to eq %w[foo bar]
      expect( Sycamore::Path['foo', 'bar', 42].to_a ).to eq ['foo', 'bar', 42]
      expect( Sycamore::Path['foo', nil, 42  ].to_a ).to eq ['foo', nil, 42]
    end
  end

  ############################################################################

  describe '#join' do
    shared_examples_for 'every join string' do |path, delimiter = '/'|
      it 'contains the to_s representation of the nodes' do
        path.each_node do |node|
          expect( path.join(delimiter) ).to include node.to_s
        end
      end
      it 'delimits the nodes with the specified delimiter' do
        expect( path.join(delimiter).count(delimiter) ).to be path.length
      end
    end

    include_examples 'every join string', Sycamore::Path[1]
    include_examples 'every join string', Sycamore::Path[:foo, 'bar', 42]
    include_examples 'every join string', Sycamore::Path[:foo, 'bar', 42], '\\'
    include_examples 'every join string', Sycamore::Path[:foo, nil, 42], '\\'
  end

  ############################################################################

  describe '#to_s' do
    shared_examples_for 'every to_s string' do |path|
      it 'starts with a Path-specific prefix' do
        expect( path.to_s ).to match /^#<Path: /
      end
      it 'contains the join string' do
        path.each_node { |node| expect( path.inspect ).to include node.inspect }
      end
    end

    include_examples 'every to_s string', Sycamore::Path[1]
    include_examples 'every to_s string', Sycamore::Path[:foo, 'bar', 42]
    include_examples 'every to_s string', Sycamore::Path[:foo, 'bar', nil]
  end

  ############################################################################

  describe '#inspect' do
    shared_examples_for 'every inspect string' do |path|
      it 'is in the usual Ruby inspect style' do
        expect( path.inspect ).to match /^#<Sycamore::Path/
      end
      it 'contains the inspect representations of all nodes' do
        path.each_node do |node|
          expect( path.inspect ).to include node.inspect
        end
      end
    end

    include_examples 'every inspect string', Sycamore::Path[1]
    include_examples 'every inspect string', Sycamore::Path[:foo, 'bar', 42]
    include_examples 'every inspect string', Sycamore::Path[nil, :foo, 'bar', 42]
  end

end
