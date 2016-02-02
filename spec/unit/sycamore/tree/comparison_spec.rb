describe Sycamore::Tree do

  ############################################################################
  # Equality
  ############################################################################

  MyTree = Class.new(Sycamore::Tree)

  EQL = [
    [ Sycamore::Tree.new   , Sycamore::Tree.new ],
    [ MyTree.new           , MyTree.new ],
    [ Sycamore::Tree.new   , Sycamore::Nothing ],
    [ MyTree.new           , Sycamore::Nothing ],
    [ Sycamore::Tree[1]    , Sycamore::Tree[1] ],
    [ Sycamore::Tree[1, 2] , Sycamore::Tree[1, 2] ],
    [ Sycamore::Tree[1, 2] , Sycamore::Tree[2, 1] ],
    [ Sycamore::Tree[a: 1] , Sycamore::Tree[a: 1] ],
    [ Sycamore::Tree[a: 1] , Sycamore::Tree[a: {1 => nil}] ],
    [ Sycamore::Tree[foo: 'foo', bar: %w[bar baz]],
      Sycamore::Tree[foo: 'foo', bar: %w[bar baz]] ],
  ]
  NOT_EQL_BY_CONTENT = [
    [ Sycamore::Tree[1]              , Sycamore::Tree[2] ],
    [ Sycamore::Tree[1]              , Sycamore::Tree[1.0] ],
    [ Sycamore::Tree[:foo, :bar]     , Sycamore::Tree['foo', 'bar'] ],
    [ Sycamore::Tree[a: 1]           , Sycamore::Tree[:a] ],
    [ Sycamore::Tree[a: 1]           , Sycamore::Tree[a: 2] ],
    [ Sycamore::Tree[1=>{2=>{3=>4}}] , Sycamore::Tree[1=>{2=>{3=>1}}] ],
  ]
  NOT_EQL_BY_TYPE = [
    [ Sycamore::Tree[a: 1] , Hash[a: 1] ],
    [ Sycamore::Tree.new   , MyTree.new ],
    [ MyTree.new           , Sycamore::Tree.new ],
  ]
  NOT_EQL = NOT_EQL_BY_CONTENT + NOT_EQL_BY_TYPE

  describe '#eql?' do
    it 'does return true, when the given value is of the same type and has eql content' do
      EQL.each do |tree, other|
        expect(tree).to eql(other),
          "expected #{tree.inspect} to eql #{other.inspect}"
      end
    end

    it 'does return false, when the content of the value tree is not eql' do
      NOT_EQL_BY_CONTENT.each do |tree, other|
        expect(tree).not_to eql(other),
          "expected #{tree.inspect} not to eql #{other.inspect}"
      end
    end

    it 'does return false, when the given value is not an instance of the same class' do
      NOT_EQL_BY_TYPE.each do |tree, other|
        expect(tree).not_to eql(other),
          "expected #{tree.inspect} not to eql #{other.inspect}"
      end
    end

    it 'does ignore empty child trees' do
      tree = Sycamore::Tree[foo: :bar]
      tree[:foo].clear
      expect(tree).to eq Sycamore::Tree[:foo]
    end
  end

  ############################################################################

  describe '#hash' do
    it 'does produce equal values, when the tree is eql' do
      EQL.each do |tree, other|
        expect( tree.hash ).to be(other.hash),
          "expected the hash of #{tree.inspect} to be also the hash of #{other.inspect}"
      end
    end

    it 'does produce different values, when the tree is not eql' do
      pending 'Currently, we accept the collision of different tree types with the same content. ' +
              'It is the simplest way to hold account of the special equivalence behaviour of thre Nothing tree.'
      NOT_EQL.each do |tree, other|
        expect(tree.hash).not_to eq(other.hash),
          "expected the hash of #{tree.inspect} not to equal the hash of #{other.inspect}"
      end
    end
  end

  ############################################################################

  MATCH = EQL + [
    [ Sycamore::Tree.new    , Sycamore::Nothing ],
    [ Sycamore::Nothing     , Sycamore::Tree.new ],
    [ Sycamore::Tree.new    , MyTree.new ],
    [ MyTree.new            , Sycamore::Tree.new ],
    [ Sycamore::Tree.new    , Hash.new ],
    [ Sycamore::Tree.new    , Array.new ],
    [ Sycamore::Tree.new    , Set.new ],
    [ Sycamore::Tree[:a ]   , :a  ],
    [ Sycamore::Tree['a']   , 'a' ],
    [ Sycamore::Tree[ 1 ]   , 1 ],
    [ Sycamore::Tree[:a]    , Hash[a: nil] ],
    [ Sycamore::Tree[:a]    , Hash[a: []] ],
    [ Sycamore::Tree[:a]    , Hash[a: {}] ],
    [ Sycamore::Tree[1,2,3] , [1,2,3]  ],
    [ Sycamore::Tree[1,2,3] , Set[1,2,3] ],
    [ Sycamore::Tree[:a,:b] , [:b, :a] ],
    [ Sycamore::Tree[a: 1]  , Hash[a: 1] ],
    [ Sycamore::Tree[foo: 'foo', bar: %w[bar baz]],
      Hash[foo: 'foo', bar: %w[bar baz]] ],
  ]
  MATCH_BY_COERCION = [
    [ Sycamore::Tree[ 1 ] , 1.0 ],
    [ Sycamore::Tree[ 1 ] , [1.0] ],
    [ Sycamore::Tree[ 1 ] , Sycamore::Tree[1.0] ],
  ]
  NO_MATCH = NOT_EQL_BY_CONTENT + [
    [ Sycamore::Tree.new             , nil ],
    [ Sycamore::Tree[ 1 ]            ,  2  ],
    [ Sycamore::Tree[ 1 ]            , '1' ],
    [ Sycamore::Tree['a']            , :a  ],
    [ Sycamore::Tree[:a]             , {a: 1} ],
    [ Sycamore::Tree[:foo, :bar]     , {foo: 1, bar: 2} ],
    [ Sycamore::Tree[:foo, :bar]     , ['foo', 'bar'] ],
    [ Sycamore::Tree[1,2,3]          , [1,2] ],
    [ Sycamore::Tree[1,2]            , [1,2,3]   ],
    [ Sycamore::Tree[1,2,3]          , [1,2,[3]] ],
    [ Sycamore::Tree[a: 1]           , :a ],
    [ Sycamore::Tree[a: 1, b: 2]     , [:a, :b] ],
    [ Sycamore::Tree[a: 1]           , {a: 2} ],
    [ Sycamore::Tree[a: 1]           , {a: {1=>2}} ],
    [ Sycamore::Tree[1=>{2=>{3=>4}}] , {1=>{2=>{3=>1}}} ],
    [ Sycamore::Tree.new        , { nil => nil } ],
    [ Sycamore::Tree[:foo]      , { foo: :bar } ],
    [ Sycamore::Tree[foo: :bar] , [:foo] ],
    [ Sycamore::Tree[1=>[2,3] ] , {1=>{2=>3}} ],
    [ Sycamore::Tree[1=>{2=>3}] , {1=>[2,3]} ],
  ]

  describe '#===' do
    it 'does return true, when the given value is structurally equivalent and has equal content' do
      MATCH.each do |tree, other|
        expect( tree === other ).to be(true),
          "expected #{tree.inspect} === #{other.inspect}"
      end
    end

    it 'does return true, when the given value is structurally equivalent and has equal content' do
      MATCH_BY_COERCION.each do |tree, other|
        pending 'matching by coercion'
        expect( tree === other ).to be(true),
          "expected #{tree.inspect} === #{other.inspect}"
      end
    end

    it 'does return false, when the given value is structurally different and has different content in terms of ==' do
      NO_MATCH.each do |tree, other|
        expect( tree === other ).to be(false),
          "expected not #{tree.inspect} === #{other.inspect}"
      end
    end

    it 'does ignore empty child trees' do
      tree = Sycamore::Tree[foo: :bar]
      tree[:foo].clear

      expect( tree === Sycamore::Tree[:foo] ).to be true
    end
  end

  ############################################################################
  # comparison
  ############################################################################

  INCLUDES_NODE = [
    [ [1, 2      ], 1 ],
    [ [1, 2      ], 2 ],
    [ [42, 'text'], 42 ],
    [ [foo: :bar ], :foo ],
  ]
  NOT_INCLUDES_NODE =[
    [ [         ], 1      ],
    [ [1        ], 2      ],
    [ [foo: :bar], :bar   ],
  ]
  INCLUDES_ENUMERABLE = [
    [ [1, 2      ], [1     ] ],
    [ [1, 2, 3   ], [1, 2  ] ],
    [ [:a, :b, :c], [:c, :a] ],
  ]
  NOT_INCLUDES_ENUMERABLE = [
    [ [            ] , [1        ] ],
    [ [1, 2        ] , [3        ] ],
    [ [1, 2        ] , [1, 3     ] ],
    [ [:a, :b, :c  ] , [:a, :b, 1] ],
    [ [a: :b, c: :d] , [:a, :d   ] ],
  ]
  INCLUDES_TREE = [
    [ [1 => 2             ], {1 => nil        } ],
    [ [1 => [2, 3]        ], {1 => 2          } ],
    [ [1 => 2, 3 => 1     ], {1 => 2          } ],
    [ [1 => [2, 3], 3 => 1], {1 => 2, 3 => 1  } ],
    [ [1 => [2, 3], 3 => 1], {1 => 2, 3 => nil} ],
  ]
  NOT_INCLUDES_TREE = [
    [ [       ] , {1 => 2         } ],
    [ [1      ] , {1 => 2         } ],
    [ [42 => 2] , {1 => 2         } ],
    [ [1 => 2 ] , {1 => [2, 3]    } ],
    [ [1 => 2 ] , {1 => 2, 3 => 1 } ],
    [ [2 => 1 ] , {1 => 2         } ],
  ]
  INCLUDES = INCLUDES_NODE + INCLUDES_ENUMERABLE + INCLUDES_TREE

  def to_tree(tree_or_data)
    return tree_or_data if tree_or_data.is_a? Sycamore::Tree
    tree_or_data = [tree_or_data] unless tree_or_data.is_a? Array
    Sycamore::Tree[*tree_or_data]
  end


  describe '#include?' do
    it 'does return true, when the given value matches the tree in terms of ===' do
      MATCH.each do |tree, other|
        expect( tree.include?(other) ).to be(true),
          "expected #{tree.inspect} to include #{other.inspect}"
      end
    end

    context 'when given a single atomic value' do
      it 'does return true, when the value is in the set of nodes' do
        INCLUDES_NODE.each do |data, other|
          tree = to_tree(data)
          expect( tree.include?(other) ).to be(true),
            "expected #{tree.inspect} to include #{other.inspect}"
        end
      end

      it 'does return false, when the value is not in the set of nodes' do
        NOT_INCLUDES_NODE.each do |data, other|
          tree = to_tree(data)
          expect( tree.include?(other) ).to be(false),
            "expected #{tree.inspect} not to include #{other.inspect}"
        end
      end
    end

    context 'when given a single enumerable' do
      it 'does return true, when all elements are in the set of nodes' do
        INCLUDES_ENUMERABLE.each do |data, other|
          tree = to_tree(data)
          expect( tree.include?(other) ).to be(true),
            "expected #{tree.inspect} to include #{other.inspect}"
          expect( tree.include?(Set[*other]) ).to be(true),
            "expected #{tree.inspect} to include Set[#{other}]"
        end
      end

      it 'does return false, when some elements are not in the set of nodes' do
        NOT_INCLUDES_ENUMERABLE.each do |data, other|
          tree = to_tree(data)
          expect( tree.include?(other) ).to be(false),
            "expected #{tree.inspect} not to include #{other.inspect}"
          expect( tree.include?(Set[*other]) ).to be(false),
            "expected #{tree.inspect} not to include Set[#{other.inspect}]"
        end
      end
    end

    context 'when given a single hash' do
      it 'does return true, when all of its elements are part of the tree and nested equally' do
        INCLUDES_TREE.each do |data, other|
          tree = to_tree(data)
          expect( tree.include?(other) ).to be(true),
            "expected #{tree.inspect} to include #{other.inspect}"
        end
      end

      it 'does return false, when some of its elements are not part of the tree' do
        NOT_INCLUDES_TREE.each do |data, other|
          tree = to_tree(data)
          expect( tree.include?(other) ).to be(false),
            "expected #{tree.inspect} not to include #{other.inspect}"
        end
      end
    end

    context 'when given another Tree' do
      it 'does return true, when all of its elements are part of the tree and nested equally' do
        INCLUDES_TREE.each do |data, other|
          tree, other_tree = to_tree(data), to_tree(other)
          expect( tree.include?(other_tree) ).to be(true),
            "expected #{tree.inspect} to include #{other_tree.inspect}"
        end
      end

      it 'does return false, when some of its elements are not part of the tree' do
        NOT_INCLUDES_TREE.each do |data, other|
          tree, other_tree = to_tree(data), to_tree(other)
          expect( tree.include?(other_tree) ).to be(false),
            "expected #{tree.inspect} not to include #{other_tree.inspect}"
        end
      end
    end

    context 'edge cases' do
      context 'when given a single value' do
        specify { expect( Sycamore::Tree[false].include? false).to be true }
        specify { expect( Sycamore::Tree[0    ].include? 0    ).to be true }
      end
    end
  end

  ############################################################################

  describe '#>=' do
    it 'does return true, when the given value is a tree and this tree includes it' do
      INCLUDES.each do |data, other|
        tree, other_tree = to_tree(data), to_tree(other)
        expect( tree >= other_tree ).to be(true),
          "expected #{tree.inspect} >= #{other_tree.inspect}"
      end
    end

    it 'does return true, when the given value is to this equal' do
      EQL.each do |tree, other_tree|
        expect( tree >= other_tree ).to be(true),
          "expected #{tree.inspect} >= #{other_tree.inspect}"
      end
    end

    it 'does return false, when the given value is not a tree' do
      expect( Sycamore::Tree[a: :b] >= [:a] ).to be false
    end
  end

  describe '#>' do
    it 'does return true, when the given value is a tree and this tree includes it' do
      INCLUDES.each do |data, other|
        tree, other_tree = to_tree(data), to_tree(other)
        expect( tree > other_tree ).to be(true),
          "expected #{tree.inspect} > #{other_tree.inspect}"
      end
    end

    it 'does return false, when the given value is to this equal' do
      EQL.each do |tree, other_tree|
        expect( tree > other_tree ).to be(false),
          "expected #{tree.inspect} > #{other_tree.inspect} to be false"
      end
    end

    it 'does return false, when the given value is not a tree' do
      expect( Sycamore::Tree[1, 2] > [1] ).to be false
    end
  end

  describe '#<' do
    it 'does return true, when the given value is a tree and includes this tree' do
      INCLUDES.each do |data, other|
        tree, other_tree = to_tree(data), to_tree(other)
        expect( other_tree < tree).to be(true),
          "expected #{other_tree.inspect} < #{tree.inspect}"
      end
    end

    it 'does return false, when the given value is to this equal' do
      EQL.each do |tree, other_tree|
        expect( other_tree < tree ).to be(false),
          "expected #{other_tree.inspect} < #{tree.inspect} to be false"
      end
    end

    it 'does return false, when the given value is not a tree' do
      expect( Sycamore::Tree[1] < {1 => 2} ).to be false
    end
  end

  describe '#<=' do
    it 'does return true, when the given value is a tree and includes this tree' do
      INCLUDES.each do |data, other|
        tree, other_tree = to_tree(data), to_tree(other)
        expect( other_tree <= tree).to be(true),
          "expected #{other_tree.inspect} <= #{tree.inspect}"
      end
    end

    it 'does return true, when the given value is to this equal' do
      EQL.each do |tree, other_tree|
        expect( tree <= other_tree ).to be(true),
          "expected #{tree.inspect} <= #{other_tree.inspect}"
      end
    end

    it 'does return false, when the given value is not a tree' do
      expect( Sycamore::Tree[1] <= {1 => 2} ).to be false
    end
  end

  ############################################################################

  # TODO: Clean this up!
  describe '#path?' do
    context 'when given a Path' do
      specify { expect( Sycamore::Tree[].path? Sycamore::Path[] ).to be true }
      specify { expect( Sycamore::Tree[].path? Sycamore::Path[42] ).to be false }
      specify { expect( Sycamore::Tree[].path? Sycamore::Path[1,2,3] ).to be false }

      specify { expect( Sycamore::Tree[1 => 2].path?(Sycamore::Path(1))).to be true }
      specify { expect( Sycamore::Tree[1 => 2].path?(Sycamore::Path(2))).to be false }
      specify { expect( Sycamore::Tree[1 => 2].path?(Sycamore::Path(1, 2))).to be true }
    end

    context 'when given a single atom' do
      specify { expect( Sycamore::Tree[1 => 2].path?(1) ).to be true }
      specify { expect( Sycamore::Tree[1 => 2].path?(2) ).to be false }
    end

    context 'when given a sequence of atoms' do

      context 'when given a single Enumerable' do
        specify { expect( Sycamore::Tree[prop1: 1, prop2: [:foo, :bar]].path?(:prop2, :foo) ).to be true }
        specify { expect( Sycamore::Tree[1 => 2].path?([1, 2])     ).to be true }
        specify { expect( Sycamore::Tree[1 => 2].path?([1, 2, 3])  ).to be false }
        specify { expect( Sycamore::Tree[1 => 2].path?([1, 2, 3])  ).to be false }
        specify { expect( Sycamore::Tree['1' => '2'].path?([1, 2]) ).to be false }
      end

      context 'when given multiple arguments' do
        specify { expect( Sycamore::Tree[prop1: 1, prop2: [:foo, :bar]].path?(:prop2, :foo) ).to be true }
        specify { expect( Sycamore::Tree[1 => 2].path?(1, 2)     ).to be true }
        specify { expect( Sycamore::Tree[1 => 2].path?(1, 2, 3)  ).to be false }
        specify { expect( Sycamore::Tree[1 => 2].path?(1, 2, 3)  ).to be false }
        specify { expect( Sycamore::Tree['1' => '2'].path?(1, 2) ).to be false }
      end
    end

    context 'when no arguments given' do
      it 'raises an ArgumentError' do
        expect { Sycamore::Tree.new.path? }.to raise_error ArgumentError
      end
    end
  end

end
