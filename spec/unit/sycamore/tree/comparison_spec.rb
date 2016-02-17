describe Sycamore::Tree do

  ############################################################################
  # Equality
  ############################################################################

  MyTree = Class.new(Sycamore::Tree)

  TREE_EQL = [
    [ Sycamore::Tree.new   , Sycamore::Tree.new ],
    [ MyTree.new           , MyTree.new ],
    [ Sycamore::Tree[1]    , Sycamore::Tree[1] ],
    [ Sycamore::Tree[1]    , Sycamore::Tree[1 => nil] ],
    [ Sycamore::Tree[1, 2] , Sycamore::Tree[1, 2] ],
    [ Sycamore::Tree[1, 2] , Sycamore::Tree[2, 1] ],
    [ Sycamore::Tree[a: 1] , Sycamore::Tree[a: 1] ],
    [ Sycamore::Tree[a: 1] , Sycamore::Tree[a: {1 => nil}] ],
    [ Sycamore::Tree[foo: 'foo', bar: %w[bar baz]],
      Sycamore::Tree[foo: 'foo', bar: %w[bar baz]] ],
  ]
  TREE_NOT_EQL_BY_CONTENT = [
    [ Sycamore::Tree[1]              , Sycamore::Tree[2] ],
    [ Sycamore::Tree[1]              , Sycamore::Tree[1.0] ],
    [ Sycamore::Tree[:foo, :bar]     , Sycamore::Tree['foo', 'bar'] ],
    [ Sycamore::Tree[a: 1]           , Sycamore::Tree[:a] ],
    [ Sycamore::Tree[a: 1]           , Sycamore::Tree[a: 2] ],
    [ Sycamore::Tree[1=>{2=>{3=>4}}] , Sycamore::Tree[1=>{2=>{3=>1}}] ],
  ]
  TREE_NOT_EQL_BY_TYPE = [
    [ Sycamore::Tree[a: 1] , Hash[a: 1] ],
    [ Sycamore::Tree.new   , MyTree.new ],
    [ MyTree.new           , Sycamore::Tree.new ],
  ]
  TREE_NOT_EQL = TREE_NOT_EQL_BY_CONTENT + TREE_NOT_EQL_BY_TYPE

  TREE_EQ_BUT_NOT_EQL = [
    [ Sycamore::Tree.new   , Sycamore::Nothing ],
    [ MyTree.new           , Sycamore::Nothing ],
    [ Sycamore::Tree[1]     , Sycamore::Tree[1 => []] ],
    [ Sycamore::Tree[1=>[]] , Sycamore::Tree[1] ],
  ]

  ############################################################################

  describe '#hash' do
    it 'does produce equal values, when the tree is eql' do
      TREE_EQL.each do |tree, other|
        expect( tree.hash ).to be(other.hash),
                               "expected the hash of #{tree.inspect} to be also the hash of #{other.inspect}"
      end
    end

    it 'does produce different values, when the tree is not eql' do
      TREE_NOT_EQL.each do |tree, other|
        expect(tree.hash).not_to eq(other.hash),
          "expected the hash of #{tree.inspect} not to equal the hash of #{other.inspect}"
      end
    end
  end

  ############################################################################

  describe '#eql?' do
    it 'does return true, when the given value is of the same type and has eql content' do
      TREE_EQL.each do |tree, other|
        expect(tree).to eql(other)
      end
    end

    it 'does return false, when the content of the value tree is not eql' do
      TREE_NOT_EQL_BY_CONTENT.each do |tree, other|
        expect(tree).not_to eql(other)
      end
    end

    it 'does return false, when the given value is not an instance of the same class' do
      TREE_NOT_EQL_BY_TYPE.each do |tree, other|
        expect(tree).not_to eql(other)
      end
    end

    it 'does consider empty child trees' do
      TREE_EQ_BUT_NOT_EQL.each do |tree, other|
        expect(tree).not_to eql(other)
      end
    end
  end

  ############################################################################

  describe '#==' do
    it 'does return true, when the given value is of the same type and has eql content' do
      TREE_EQL.each do |tree, other|
        expect(tree).to eq(other)
      end
    end

    it 'does return false, when the content of the value tree is not eql' do
      TREE_NOT_EQL_BY_CONTENT.each do |tree, other|
        expect(tree).not_to eq(other)
      end
    end

    it 'does return false, when the given value is not an instance of the same class' do
      TREE_NOT_EQL_BY_TYPE.each do |tree, other|
        expect(tree).not_to eq(other)
      end
    end

    it 'does ignore empty child trees' do
      TREE_EQ_BUT_NOT_EQL.each do |tree, other|
        expect(tree).to eq(other)
      end
    end
  end

  ############################################################################

  TREE_MATCH = TREE_EQL + TREE_EQ_BUT_NOT_EQL + [
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
  TREE_MATCH_BY_COERCION = [
    [ Sycamore::Tree[ 1 ] , 1.0 ],
    [ Sycamore::Tree[ 1 ] , [1.0] ],
    [ Sycamore::Tree[ 1 ] , Sycamore::Tree[1.0] ],
  ]
  TREE_NO_MATCH = TREE_NOT_EQL_BY_CONTENT + [
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

  ############################################################################

  describe '#===' do
    it 'does return true, when the given value is structurally equivalent and has equal content' do
      TREE_MATCH.each do |tree, other|
        expect( tree === other ).to be(true),
          "expected #{tree.inspect} === #{other.inspect}"
      end
    end

    # see comment on Tree#matches?
    # it 'does return true, when the given value is structurally equivalent and has equal content' do
    #   TREE_MATCH_BY_COERCION.each do |tree, other|
    #     pending 'matching by coercion'
    #     expect( tree === other ).to be(true),
    #       "expected #{tree.inspect} === #{other.inspect}"
    #   end
    # end

    it 'does return false, when the given value is structurally different and has different content in terms of ==' do
      TREE_NO_MATCH.each do |tree, other|
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

  TREE_INCLUDES_NODE = [
    [ [1, 2      ], 1 ],
    [ [1, 2      ], 2 ],
    [ [42, 'text'], 42 ],
    [ [foo: :bar ], :foo ],
  ]
  TREE_NOT_INCLUDES_NODE =[
    [ [         ], 1      ],
    [ [1        ], 2      ],
    [ [foo: :bar], :bar   ],
  ]
  TREE_INCLUDES_ENUMERABLE = [
    [ [1, 2      ], [1     ] ],
    [ [1, 2, 3   ], [1, 2  ] ],
    [ [:a, :b, :c], [:c, :a] ],
  ]
  TREE_NOT_INCLUDES_ENUMERABLE = [
    [ [            ] , [1        ] ],
    [ [1, 2        ] , [3        ] ],
    [ [1, 2        ] , [1, 3     ] ],
    [ [:a, :b, :c  ] , [:a, :b, 1] ],
    [ [a: :b, c: :d] , [:a, :d   ] ],
  ]
  TREE_INCLUDES_TREE = [
    [ [1 => 2             ], {1 => nil        } ],
    [ [1 => [2, 3]        ], {1 => 2          } ],
    [ [1 => 2, 3 => 1     ], {1 => 2          } ],
    [ [1 => [2, 3], 3 => 1], {1 => 2, 3 => 1  } ],
    [ [1 => [2, 3], 3 => 1], {1 => 2, 3 => nil} ],
  ]
  TREE_NOT_INCLUDES_TREE = [
    [ [       ] , {1 => 2         } ],
    [ [1      ] , {1 => 2         } ],
    [ [42 => 2] , {1 => 2         } ],
    [ [1 => 2 ] , {1 => [2, 3]    } ],
    [ [1 => 2 ] , {1 => 2, 3 => 1 } ],
    [ [2 => 1 ] , {1 => 2         } ],
  ]
  TREE_INCLUDES = TREE_INCLUDES_NODE + TREE_INCLUDES_ENUMERABLE + TREE_INCLUDES_TREE

  def to_tree(tree_or_data)
    return tree_or_data if tree_or_data.is_a? Sycamore::Tree
    tree_or_data = [tree_or_data] unless tree_or_data.is_a? Array
    Sycamore::Tree[*tree_or_data]
  end

  ############################################################################

  describe '#include?' do
    it 'does return true, when the given value matches the tree in terms of ===' do
      TREE_MATCH.each do |tree, other|
        expect( tree.include?(other) ).to be(true),
          "expected #{tree.inspect} to include #{other.inspect}"
      end
    end

    context 'when given a single atomic value' do
      it 'does return true, when the value is in the set of nodes' do
        TREE_INCLUDES_NODE.each do |data, other|
          tree = to_tree(data)
          expect( tree.include?(other) ).to be(true),
            "expected #{tree.inspect} to include #{other.inspect}"
        end
      end

      it 'does return false, when the value is not in the set of nodes' do
        TREE_NOT_INCLUDES_NODE.each do |data, other|
          tree = to_tree(data)
          expect( tree.include?(other) ).to be(false),
            "expected #{tree.inspect} not to include #{other.inspect}"
        end
      end
    end

    context 'when given a single enumerable' do
      it 'does return true, when all elements are in the set of nodes' do
        TREE_INCLUDES_ENUMERABLE.each do |data, other|
          tree = to_tree(data)
          expect( tree.include?(other) ).to be(true),
            "expected #{tree.inspect} to include #{other.inspect}"
          expect( tree.include?(Set[*other]) ).to be(true),
            "expected #{tree.inspect} to include Set[#{other}]"
        end
      end

      it 'does return false, when some elements are not in the set of nodes' do
        TREE_NOT_INCLUDES_ENUMERABLE.each do |data, other|
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
        TREE_INCLUDES_TREE.each do |data, other|
          tree = to_tree(data)
          expect( tree.include?(other) ).to be(true),
            "expected #{tree.inspect} to include #{other.inspect}"
        end
      end

      it 'does return false, when some of its elements are not part of the tree' do
        TREE_NOT_INCLUDES_TREE.each do |data, other|
          tree = to_tree(data)
          expect( tree.include?(other) ).to be(false),
            "expected #{tree.inspect} not to include #{other.inspect}"
        end
      end
    end

    context 'when given another Tree' do
      it 'does return true, when all of its elements are part of the tree and nested equally' do
        TREE_INCLUDES_TREE.each do |data, other|
          tree, other_tree = to_tree(data), to_tree(other)
          expect( tree.include?(other_tree) ).to be(true),
            "expected #{tree.inspect} to include #{other_tree.inspect}"
        end
      end

      it 'does return false, when some of its elements are not part of the tree' do
        TREE_NOT_INCLUDES_TREE.each do |data, other|
          tree, other_tree = to_tree(data), to_tree(other)
          expect( tree.include?(other_tree) ).to be(false),
            "expected #{tree.inspect} not to include #{other_tree.inspect}"
        end
      end
    end

    context 'when given a Path' do
      it 'does delegate to include_path?' do
        tree = Sycamore::Tree[foo: :bar]
        path = Sycamore::Path[:foo, :bar]
        expect( tree ).to receive(:include_path?).with(path)
        tree.include?(path)
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
      TREE_INCLUDES.each do |data, other|
        tree, other_tree = to_tree(data), to_tree(other)
        expect( tree >= other_tree ).to be(true),
          "expected #{tree.inspect} >= #{other_tree.inspect}"
      end
    end

    it 'considers Absence to be a tree' do
      absence = Sycamore::Absence.at(Sycamore::Tree.new, :missing)
      absence << :a
      expect( Sycamore::Tree[a: :b] >= absence ).to be true
    end

    it 'does return true, when the given tree is equal' do
      TREE_EQL.each do |tree, other_tree|
        expect( tree >= other_tree ).to be(true),
          "expected #{tree.inspect} >= #{other_tree.inspect}"
      end
    end

    it 'does return false, when the given value is not a tree' do
      expect( Sycamore::Tree[a: :b] >= [:a] ).to be false
    end
  end

  ############################################################################

  describe '#>' do
    it 'does return true, when the given value is a tree and this tree includes it' do
      TREE_INCLUDES.each do |data, other|
        tree, other_tree = to_tree(data), to_tree(other)
        expect( tree > other_tree ).to be(true),
          "expected #{tree.inspect} > #{other_tree.inspect}"
      end
    end

    it 'considers Absence to be a tree' do
      absence = Sycamore::Absence.at(Sycamore::Tree.new, :missing)
      absence << :a
      expect( Sycamore::Tree[a: :b] > absence ).to be true
    end

    it 'does return false, when the given tree is equal' do
      TREE_EQL.each do |tree, other_tree|
        expect( tree > other_tree ).to be(false),
          "expected #{tree.inspect} > #{other_tree.inspect} to be false"
      end
    end

    it 'does return false, when the given value is not a tree' do
      expect( Sycamore::Tree[1, 2] > [1] ).to be false
    end
  end

  ############################################################################

  describe '#<' do
    it 'does return true, when the given value is a tree and includes this tree' do
      TREE_INCLUDES.each do |data, other|
        tree, other_tree = to_tree(data), to_tree(other)
        expect( other_tree < tree).to be(true),
          "expected #{other_tree.inspect} < #{tree.inspect}"
      end
    end

    it 'considers Absence to be a tree' do
      absence = Sycamore::Absence.at(Sycamore::Tree.new, :missing)
      absence << {a: :b}
      expect( Sycamore::Tree[:a] < absence ).to be true
    end

    it 'does return false, when the given tree is equal' do
      TREE_EQL.each do |tree, other_tree|
        expect( other_tree < tree ).to be(false),
          "expected #{other_tree.inspect} < #{tree.inspect} to be false"
      end
    end

    it 'does return false, when the given value is not a tree' do
      expect( Sycamore::Tree[1] < {1 => 2} ).to be false
    end
  end

  ############################################################################

  describe '#<=' do
    it 'does return true, when the given value is a tree and includes this tree' do
      TREE_INCLUDES.each do |data, other|
        tree, other_tree = to_tree(data), to_tree(other)
        expect( other_tree <= tree).to be(true),
          "expected #{other_tree.inspect} <= #{tree.inspect}"
      end
    end

    it 'considers Absence to be a tree' do
      absence = Sycamore::Absence.at(Sycamore::Tree.new, :missing)
      absence << {a: :b}
      expect( Sycamore::Tree[:a] <= absence ).to be true
    end

    it 'does return true, when the given tree is equal' do
      TREE_EQL.each do |tree, other_tree|
        expect( tree <= other_tree ).to be(true),
          "expected #{tree.inspect} <= #{other_tree.inspect}"
      end
    end

    it 'does return false, when the given value is not a tree' do
      expect( Sycamore::Tree[1] <= {1 => 2} ).to be false
    end
  end

  ############################################################################

  describe '#include_path?' do
    HAS_PATH_EXAMPLES = [
      # Path    , Tree
      [ [1]     , [1] ],
      [ [1, 2]  , {1 => 2} ],
      [ [1]     , {1 => {2 => 3, 4 => 5}} ],
      [ [1,2]   , {1 => {2 => 3, 4 => 5}} ],
      [ [1,2,3] , {1 => {2 => 3, 4 => 5}} ],
      [ [1,2]   , {1 => [2, 3]} ],
      [ [1,2,3] , {1 => {2 => [3], 4 => 5}} ],
    ]

    NOT_HAS_PATH_EXAMPLES = [
      # Path    , Tree
      [ [1]     , [] ],
      [ [2]     , {1 => 2} ],
      [ [1,2,3] , {1 => 2} ],
    ]

    context 'when given a nodes path as one or more node arguments' do
      it 'does return true, if the given nodes path is present' do
        HAS_PATH_EXAMPLES.each do |path_nodes, struct|
          tree = Sycamore::Tree[struct]
          expect( tree.include_path?(*path_nodes) ).to be(true),
            "expected #{tree.inspect} to include path #{path_nodes.inspect}"
        end
      end

      it 'does return false, if the given nodes path is present' do
        NOT_HAS_PATH_EXAMPLES.each do |path_nodes, struct|
          tree = Sycamore::Tree[struct]
          expect( tree.include_path?(*path_nodes) ).to be(false),
            "expected #{tree.inspect} to not include path #{path_nodes.inspect}"
        end
      end
    end

    context 'when given a nodes path as an enumerable of nodes' do
      it 'does return true, if the given nodes path is present' do
        HAS_PATH_EXAMPLES.each do |path_nodes, struct|
          tree = Sycamore::Tree[struct]
          expect( tree.include_path?(path_nodes) ).to be(true),
            "expected #{tree.inspect} to include path #{path_nodes.inspect}"
        end
      end

      it 'does return false, if the given nodes path is present' do
        NOT_HAS_PATH_EXAMPLES.each do |path_nodes, struct|
          tree = Sycamore::Tree[struct]
          expect( tree.include_path?(path_nodes) ).to be(false),
            "expected #{tree.inspect} to not include path #{path_nodes.inspect}"
        end
      end
    end

    context 'when given a nodes path as a Sycamore::Path' do
      it 'does return true, if the given nodes path is present' do
        HAS_PATH_EXAMPLES.each do |path_nodes, struct|
          tree = Sycamore::Tree[struct]
          expect( tree.include_path?(Sycamore::Path[path_nodes]) ).to be(true),
            "expected #{tree.inspect} to include path #{path_nodes.inspect}"
        end
      end

      it 'does return false, if the given nodes path is present' do
        NOT_HAS_PATH_EXAMPLES.each do |path_nodes, struct|
          tree = Sycamore::Tree[struct]
          expect( tree.include_path?(Sycamore::Path[path_nodes]) ).to be(false),
            "expected #{tree.inspect} to not include path #{path_nodes.inspect}"
        end
      end
    end

    context 'edge cases' do
      it 'raises an error, when given no arguments' do
        expect { Sycamore::Tree.new.path? }.to raise_error ArgumentError
      end

      it 'raises an error, when given multiple collections' do
        expect { Sycamore::Tree.new.path?([1,2], [3,4]) }.to raise_error Sycamore::InvalidNode
      end

      it 'raises an error, when given multiple paths' do
        expect { Sycamore::Tree.new.path?(Sycamore::Path[1,2], Sycamore::Path[3,4]) }.to raise_error Sycamore::InvalidNode
      end
    end
  end

end
