describe Sycamore::Tree do

  MyTree = Class.new(Sycamore::Tree)

  EQL = [
    [ Sycamore::Tree.new   , Sycamore::Tree.new ],
    [ MyTree.new           , MyTree.new ],
    [ Sycamore::Tree[1]    , Sycamore::Tree[1] ],
    [ Sycamore::Tree[1, 2] , Sycamore::Tree[2, 1] ],
    [ Sycamore::Tree[a: 1] , Sycamore::Tree[a: 1] ],
    [ Sycamore::Tree[foo: 'foo', bar: %w[bar baz]],
      Sycamore::Tree[foo: 'foo', bar: %w[bar baz]] ],
  ]

  NOT_EQL_BY_CONTENT = [
    [ Sycamore::Tree[1]              , Sycamore::Tree[2] ],
    [ Sycamore::Tree[1]              , Sycamore::Tree[1.0] ],
    [ Sycamore::Tree[:foo, :bar]     , Sycamore::Tree['foo', 'bar'] ],
    [ Sycamore::Tree[a: 1]           , Sycamore::Tree[a: 2] ],
    [ Sycamore::Tree[1=>{2=>{3=>4}}] , Sycamore::Tree[1=>{2=>{3=>1}}] ],
  ]

  NOT_EQL_BY_TYPE = [
    [ Sycamore::Tree[a: 1] , Hash[a: 1] ],
    [ Sycamore::Tree.new   , Sycamore::Nothing ],
    [ Sycamore::Tree.new   , MyTree.new ],
    [ MyTree.new           , Sycamore::Tree.new ],
  ]

  NOT_EQL = NOT_EQL_BY_CONTENT + NOT_EQL_BY_TYPE

  describe '#eql?' do
    it 'does return true, if other is of the same type and has eql content' do
      EQL.each do |tree, other|
        expect(tree).to eql(other),
          "expected #{tree.inspect} to eql #{other.inspect}"
      end
    end

    it 'does return false, if the content is not eql' do
      NOT_EQL_BY_CONTENT.each do |tree, other|
        expect(tree).not_to eql(other),
          "expected #{tree.inspect} not to eql #{other.inspect}"
      end
    end

    it 'does return false, if the other is not an instance of the same class' do
      NOT_EQL_BY_TYPE.each do |tree, other|
        expect(tree).not_to eql(other),
          "expected #{tree.inspect} not to eql #{other.inspect}"
      end
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
    [ Sycamore::Tree.new    , nil ],

    [ Sycamore::Tree[:a ]   , :a  ],
    [ Sycamore::Tree['a']   , 'a' ],
    [ Sycamore::Tree[ 1 ]   , 1 ],
    [ Sycamore::Tree[ 1 ]   , 1.0 ],    # TODO: This is not consistent with the fact that
    [ Sycamore::Tree[ 1 ]   , [1.0] ],  # TODO: not Sycamore::Tree[1] === Sycamore::Tree[1.0]
    [ Sycamore::Tree[:a]    , Hash[a: nil] ],
    [ Sycamore::Tree[1,2,3] , [1,2,3]  ],
    [ Sycamore::Tree[1,2,3] , Set[1,2,3] ],
    [ Sycamore::Tree[:a,:b] , [:b, :a] ],
    [ Sycamore::Tree[a: 1]  , Hash[a: 1] ],
    [ Sycamore::Tree[foo: 'foo', bar: %w[bar baz]],
                Hash[foo: 'foo', bar: %w[bar baz]] ],
  ]

  NO_MATCH = NOT_EQL_BY_CONTENT + [
    [ Sycamore::Tree[ 1 ]            ,  2  ],
    [ Sycamore::Tree[ 1 ]            , '1' ],
    [ Sycamore::Tree['a']            , :a  ],
    [ Sycamore::Tree[:foo, :bar]     , ['foo', 'bar'] ],
    [ Sycamore::Tree[1,2,3]          , [1,2] ],
    [ Sycamore::Tree[1,2]            , [1,2,3]   ],
    [ Sycamore::Tree[1,2,3]          , [1,2,[3]] ],
    [ Sycamore::Tree[a: 1]           , {a: 2} ],
    [ Sycamore::Tree[1=>{2=>{3=>4}}] , {1=>{2=>{3=>1}}} ],

    [ Sycamore::Tree.new        , { nil => nil } ],
    [ Sycamore::Tree[:foo]      , { foo: :bar } ],
    [ Sycamore::Tree[foo: :bar] , [:foo] ],
    [ Sycamore::Tree[1=>[2,3] ] , {1=>{2=>3}} ],
    [ Sycamore::Tree[1=>{2=>3}] , {1=>[2,3]} ],
  ]

  describe '#===' do
    it 'does return true, if the other is structurally equivalent and has equal content' do
      MATCH.each do |tree, other|
        expect( tree === other ).to be(true),
          "expected #{tree.inspect} === #{other.inspect}"
      end
    end

    it 'does return false, if the other is structurally different and has different content in terms of ==' do
      NO_MATCH.each do |tree, other|
        expect( tree === other ).to be(false),
          "expected not #{tree.inspect} === #{other.inspect}"
      end
    end
  end

end
