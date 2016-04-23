describe Sycamore::Tree do

  subject(:tree) { Sycamore::Tree.new }

  describe '#nodes' do
    context 'when empty' do
      it 'does return an empty array' do
        expect( Sycamore::Tree.new.nodes ).to eql []
      end
    end

    context 'when containing a single node' do
      context 'without children' do
        it 'does return an array with the node' do
          expect( Sycamore::Tree[1].nodes ).to eql [1]
        end
      end

      context 'with children' do
        it 'does return an array with the node only' do
          expect( Sycamore::Tree[1 => [2,3]].nodes ).to eql [1]
        end
      end
    end

    context 'when containing multiple nodes' do
      context 'without children' do
        it 'does return an array with the nodes' do
          expect( Sycamore::Tree[:foo, :bar, :baz].nodes.to_set )
            .to eql %i[foo bar baz].to_set
        end
      end

      context 'with children' do
        it 'does return an array with the nodes only' do
          expect( Sycamore::Tree[foo: 1, bar: 2, baz: nil].nodes.to_set )
            .to eql %i[foo bar baz].to_set
        end
      end
    end
  end

  ############################################################################

  describe '#node' do
    context 'when empty' do
      it 'does return nil' do
        expect( Sycamore::Tree.new.node ).to eql nil
      end
    end

    context 'when containing a single node' do
      context 'without children' do
        it 'does return the node' do
          expect( Sycamore::Tree[1].node ).to eql 1
        end
      end

      context 'with children' do
        it 'does return the node' do
          expect( Sycamore::Tree[1 => [2,3]].node ).to eql 1
        end
      end
    end

    context 'when containing multiple nodes' do
      it 'does raise an error' do
        expect { Sycamore::Tree[:foo, :bar].node }.to raise_error Sycamore::NonUniqueNodeSet
        expect { Sycamore::Tree[foo: 1, bar: 2, baz: nil].node }.to raise_error Sycamore::NonUniqueNodeSet
      end
    end
  end

  ############################################################################

  describe '#node!' do
    context 'when empty' do
      it 'does raise an error' do
        expect { Sycamore::Tree.new.node! }.to raise_error Sycamore::EmptyNodeSet
      end
    end

    context 'when containing a single node' do
      context 'without children' do
        it 'does return the node' do
          expect( Sycamore::Tree[1].node! ).to eql 1
        end
      end

      context 'with children' do
        it 'does return the node' do
          expect( Sycamore::Tree[1 => [2,3]].node! ).to eql 1
        end
      end
    end

    context 'when containing multiple nodes' do
      it 'does raise a TypeError' do
        expect { Sycamore::Tree[:foo, :bar].node! }.to raise_error Sycamore::NonUniqueNodeSet
        expect { Sycamore::Tree[foo: 1, bar: 2, baz: nil].node! }.to raise_error Sycamore::NonUniqueNodeSet
      end
    end
  end

  ############################################################################

  describe '#child_of' do
    it 'does return the child tree of the given node, when the given the node is present' do
      expect( Sycamore::Tree[property: :value].child_of(:property).node ).to be :value
    end

    it 'does return an absent tree, when the given node is a leaf' do
      expect( Sycamore::Tree[42].child_of(42) ).to be_a Sycamore::Absence
    end

    it 'does return an absent tree, when the given the node is not present' do
      expect( Sycamore::Tree.new.child_of(:missing) ).to be_a Sycamore::Absence
    end

    context 'edge cases' do
      it 'does treat nil like any other value' do
        expect( Sycamore::Tree[nil => 42].child_of(nil).node ).to be 42
        expect( Sycamore::Tree[4 => {nil => 2}].child_of(4) ).to eql Sycamore::Tree[nil => 2]
        expect( Sycamore::Tree[nil => 42].child_of(nil).node ).to be 42
        expect( Sycamore::Tree[nil].child_of(nil) ).to be_a Sycamore::Absence
        expect( Sycamore::Tree.new.child_of(nil) ).to be_a Sycamore::Absence
      end

      it 'does treat false like any other value' do
        expect( Sycamore::Tree[false => 42].child_of(false).node ).to be 42
        expect( Sycamore::Tree[4 => {false => 2}].child_of(4) ).to eql Sycamore::Tree[false => 2]
        expect( Sycamore::Tree[false => 42].child_of(false).node ).to be 42
        expect( Sycamore::Tree[false].child_of(false) ).to be_a Sycamore::Absence
        expect( Sycamore::Tree.new.child_of(false   ) ).to be_a Sycamore::Absence
      end

      it 'does raise an error, when given the Nothing tree' do
        expect { Sycamore::Tree.new.child_of(Sycamore::Nothing) }.to raise_error Sycamore::InvalidNode
      end

      it 'does raise an error, when given an Enumerable' do
        expect { Sycamore::Tree.new.child_of([1]) }.to raise_error Sycamore::InvalidNode
        expect { Sycamore::Tree.new.child_of([1, 2]) }.to raise_error Sycamore::InvalidNode
        expect { Sycamore::Tree.new.child_of(foo: :bar) }.to raise_error Sycamore::InvalidNode
        expect { Sycamore::Tree.new.child_of(Sycamore::Tree[1]) }.to raise_error Sycamore::InvalidNode
      end
    end
  end

  ############################################################################

  describe '#child_at' do
    context 'when given a path as a sequence of nodes' do
      it 'does return the child tree of the given node, when the node at the given path is present' do
        expect( Sycamore::Tree[property: :value].child_at(:property).node ).to be :value

        expect( Sycamore::Tree[1 => {2 => 3}].child_at(1, 2).node ).to be 3
        expect( Sycamore::Tree[1 => {2 => 3}].child_at([1, 2]).node ).to be 3
      end

      it 'does return an absent tree, when the node at the given path is a leaf' do
        expect( Sycamore::Tree[42       ].child_at(42       ) ).to be_a Sycamore::Absence
        expect( Sycamore::Tree[1=>{2=>3}].child_at(1, 2, 3  ) ).to be_a Sycamore::Absence
        expect( Sycamore::Tree[1=>{2=>3}].child_at([1, 2, 3]) ).to be_a Sycamore::Absence
      end

      context 'when the node at the given path is not present' do
        it 'does return an absent tree' do
          expect( Sycamore::Tree.new.child_at(:missing ) ).to be_a Sycamore::Absence
          expect( Sycamore::Tree.new.child_at( 1, 2, 3 ) ).to be_a Sycamore::Absence
          expect( Sycamore::Tree.new.child_at([1, 2, 3]) ).to be_a Sycamore::Absence
        end

        it 'does return a correctly configured absent tree' do
          tree = Sycamore::Tree.new
          absent_tree = tree.child_at(1, 2, 3)
          absent_tree << 4
          expect(tree).to eql Sycamore::Tree[1=>{2=>{3=>4}}]
        end
      end
    end

    context 'when given a path as a Sycamore::Path object' do
      it 'does return the child tree of the given node, when the node at the given path is present' do
        expect( Sycamore::Tree[property: :value].child_at(Sycamore::Path[:property]).node ).to be :value
        expect( Sycamore::Tree[1 => {2 => 3}].child_at(Sycamore::Path[1, 2]).node ).to be 3
      end

      it 'does return an absent tree, when the node at the given path is a leaf' do
        expect( Sycamore::Tree[42   ].child_at(Sycamore::Path[42]     ) ).to be_a Sycamore::Absence
        expect( Sycamore::Tree[1,2,3].child_at(Sycamore::Path[1, 2, 3]) ).to be_a Sycamore::Absence
      end

      context 'when the node at the given path is not present' do
        it 'does return an absent tree' do
          expect( Sycamore::Tree.new.child_at(Sycamore::Path[:missing]) ).to be_a Sycamore::Absence
          expect( Sycamore::Tree.new.child_at(Sycamore::Path[1, 2, 3 ]) ).to be_a Sycamore::Absence
        end

        it 'does return a correctly configured absent tree' do
          tree = Sycamore::Tree.new
          absent_tree = tree.child_at(Sycamore::Path[1, 2, 3])
          absent_tree << 4
          expect(tree).to eql Sycamore::Tree[1=>{2=>{3=>4}}]
        end
      end
    end

    context 'edge cases' do
      it 'does raise an ArgumentError, when given no arguments' do
        expect { Sycamore::Tree.new.child_at() }.to raise_error ArgumentError
      end

      it 'does raise an ArgumentError, when given an empty enumerable' do
        expect { Sycamore::Tree.new.child_at([]) }.to raise_error ArgumentError
        expect { Sycamore::Tree.new.child_at(Sycamore::Path[]) }.to raise_error ArgumentError
      end

      it 'does treat nil like any other value' do
        expect( Sycamore::Tree[nil => 42     ].child_at(nil).node     ).to be 42
        expect( Sycamore::Tree[4 => {nil => 2} ].child_at(4) ).to eq Sycamore::Tree[nil => 2]
        expect( Sycamore::Tree[1 => {nil => 3}].child_at(1, nil).node ).to be 3
        expect( Sycamore::Tree[nil => {nil => nil}].child_at(nil, nil).node ).to be nil
        expect( Sycamore::Tree[nil => nil].child_at(nil, nil) ).to be_a Sycamore::Absence
        expect( Sycamore::Tree.new.child_at(nil, nil) ).to be_a Sycamore::Absence

        tree = Sycamore::Tree.new
        absent_tree = tree.child_at(nil, nil, nil)
        absent_tree << nil
        expect(tree).to eql Sycamore::Tree[nil => {nil => {nil => [nil]}}]

        expect( Sycamore::Tree[nil => 42       ].child_at(Sycamore::Path[nil]).node     ).to be 42
        expect( Sycamore::Tree[4 => {nil => 2} ].child_at(Sycamore::Path[4]) ).to eq Sycamore::Tree[nil => 2]
      end

      it 'does treat boolean values like any other value' do
        expect( Sycamore::Tree[false => 42      ].child_at(false).node     ).to be 42
        expect( Sycamore::Tree[4 => {false => 2}].child_at(4) ).to eq Sycamore::Tree[false => 2]
        expect( Sycamore::Tree[1 => {false => 3}].child_at(1, false).node ).to be 3
        expect( Sycamore::Tree[false => {false => false}].child_at(false, false).node ).to be false
        expect( Sycamore::Tree[false => false].child_at(false, false) ).to be_a Sycamore::Absence
        expect( Sycamore::Tree.new.child_at(false, false) ).to be_a Sycamore::Absence

        tree = Sycamore::Tree.new
        absent_tree = tree.child_at(false, false, false)
        absent_tree << false
        expect(tree).to eql Sycamore::Tree[false => {false => {false => false}}]

        expect( Sycamore::Tree[false => 42       ].child_at(Sycamore::Path[false]).node     ).to be 42
        expect( Sycamore::Tree[4 => {false => 2} ].child_at(Sycamore::Path[4]) ).to eq Sycamore::Tree[false => 2]
      end
    end
  end

  ############################################################################

  describe '#fetch' do
    let(:example_tree) { Sycamore::Tree[foo: {bar: :baz}] }

    context 'when given no default value or block' do
      it 'does return the child tree of the given node, when the given the node is present' do
        expect( Sycamore::Tree[property: :value].fetch(:property).node ).to be :value
        expect( Sycamore::Tree[false => 42     ].fetch(false).node     ).to be 42
        expect( Sycamore::Tree[true  => 42     ].fetch(true).node      ).to be 42
        expect( example_tree.fetch(:foo) ).to be example_tree.child_of(:foo)
      end

      it 'does raise an error, when the given node has no child tree' do
        expect { Sycamore::Tree[42   ].fetch(42   ) }.to raise_error KeyError
        expect { Sycamore::Tree[false].fetch(false) }.to raise_error KeyError
        expect { Sycamore::Tree[true ].fetch(true)  }.to raise_error KeyError
      end

      it 'does raise an error, when the given the node is not present' do
        expect { Sycamore::Tree.new.fetch(:missing) }.to raise_error KeyError
        expect { Sycamore::Tree[false].fetch(true)  }.to raise_error KeyError
        expect { Sycamore::Tree[true ].fetch(false) }.to raise_error KeyError
      end
    end

    context 'when given a default value' do
      it 'does return the child tree of the given node, when the given the node is present' do
        expect( Sycamore::Tree[property: :value].fetch(:property, :default).node ).to be :value
        expect( Sycamore::Tree[false => 42     ].fetch(false    , true).node ).to be 42
        expect( Sycamore::Tree[true  => 42     ].fetch(true     , false).node ).to be 42
        expect( example_tree.fetch(:foo, :default) ).to be example_tree.child_of(:foo)
      end

      it 'does return the given default value, when the given node has no child tree' do
        expect( Sycamore::Tree[:miss].fetch(:miss, :default) ).to be :default
        expect( Sycamore::Tree[false].fetch(false, :default) ).to be :default
        expect( Sycamore::Tree[true ].fetch(true , :default) ).to be :default
      end

      it 'does return the given default value, when the given the node is not present' do
        expect( Sycamore::Tree.new.fetch(:miss   , :default) ).to be :default
        expect( Sycamore::Tree[false].fetch(true , :default) ).to be :default
        expect( Sycamore::Tree[true ].fetch(false, :default) ).to be :default
      end
    end

    context 'when given a default block' do
      it 'does return the child tree of the given node, when the given the node is present' do
        expect( Sycamore::Tree[property: :value].fetch(:property) { :default }.node ).to be :value
        expect( Sycamore::Tree[false => 42     ].fetch(false    ) { true }.node ).to be 42
        expect( Sycamore::Tree[true  => 42     ].fetch(true     ) { false }.node ).to be 42
        expect( example_tree.fetch(:foo, :default) ).to be example_tree.child_of(:foo)
      end

      it 'does return the evaluation result of given block, when the given node has no child tree' do
        expect( Sycamore::Tree[:miss].fetch(:miss) { :default } ).to be :default
        expect( Sycamore::Tree[false].fetch(false) { :default } ).to be :default
        expect( Sycamore::Tree[true ].fetch(true ) { :default } ).to be :default
      end

      it 'does return the evaluation result of given block, when the given the node is not present' do
        expect( Sycamore::Tree.new.fetch(:miss   ) { :default } ).to be :default
        expect( Sycamore::Tree[false].fetch(true ) { :default } ).to be :default
        expect( Sycamore::Tree[true ].fetch(false) { :default } ).to be :default
      end
    end

    context 'when given a path object' do
      it 'does return the child tree of the node at the given given path, when present' do
        expect( example_tree.fetch Sycamore::Path[:foo]       ).to eql Sycamore::Tree[bar: :baz]
        expect( example_tree.fetch Sycamore::Path[:foo, :bar] ).to eql Sycamore::Tree[:baz]
      end

      it 'does behave like fetch, when no child tree at the given path present' do
        expect { example_tree.fetch Sycamore::Path[:missing_node, :foo]       }.to raise_error KeyError, /missing_node/
        expect { example_tree.fetch Sycamore::Path[:foo, :missing_node, :baz] }.to raise_error KeyError, /missing_node/
        expect { example_tree.fetch Sycamore::Path[:foo, :bar, :missing_node] }.to raise_error KeyError, /missing_node/
        expect { example_tree.fetch Sycamore::Path[:foo, :bar, :baz]     }.to raise_error Sycamore::ChildError, 'node :baz has no child tree'

        expect( example_tree.fetch(Sycamore::Path[:missing, :foo      ], :default)    ).to be :default
        expect( example_tree.fetch(Sycamore::Path[:foo, :missing, :baz]) { :default } ).to be :default
        expect( example_tree.fetch(Sycamore::Path[:foo, :bar, :missing], :default)    ).to be :default
        expect( example_tree.fetch(Sycamore::Path[:foo, :bar, :baz]) { :default }     ).to be :default
      end
    end

    context 'edge cases' do
      it 'does treat nil like any other value' do
        expect { Sycamore::Tree.new.fetch(nil) }.to raise_error KeyError
        expect( Sycamore::Tree.new.fetch(nil, :default) ).to be :default
        expect( Sycamore::Tree.new.fetch(nil) { :default } ).to be :default

        expect { Sycamore::Tree[nil].fetch(nil) }.to raise_error KeyError
        expect( Sycamore::Tree[nil].fetch(nil, :default) ).to be :default
        expect( Sycamore::Tree[nil].fetch(nil) { :default } ).to be :default

        expect( Sycamore::Tree[nil => :foo].fetch(nil).node ).to be :foo
        expect( Sycamore::Tree[nil => :foo].fetch(nil, :default).node ).to be :foo
        expect( Sycamore::Tree[nil => :foo].fetch(nil) { :default }.node ).to be :foo
      end

      it 'does raise an error, when given the Nothing tree' do
        expect { Sycamore::Tree.new.fetch(Sycamore::Nothing) }.to raise_error Sycamore::InvalidNode
        expect { Sycamore::Tree.new.fetch(Sycamore::Nothing, :default) }.to raise_error Sycamore::InvalidNode
        expect { Sycamore::Tree.new.fetch(Sycamore::Nothing) { 42 } }.to raise_error Sycamore::InvalidNode
      end

      it 'does raise an error, when given an Enumerable' do
        expect { Sycamore::Tree.new.fetch([1]) }.to raise_error Sycamore::InvalidNode
        expect { Sycamore::Tree.new.fetch(foo: :bar) }.to raise_error Sycamore::InvalidNode
        expect { Sycamore::Tree.new.fetch(Sycamore::Tree[1]) }.to raise_error Sycamore::InvalidNode
      end
    end
  end

  ############################################################################

  describe '#fetch_path' do
    let(:example_tree) { Sycamore::Tree[foo: {bar: :baz}] }


    context 'when given a nodes path as an enumerable of nodes' do
      it 'does return the child tree of the node at the given given path, when present' do
        expect( example_tree.fetch_path [:foo]       ).to eql Sycamore::Tree[bar: :baz]
        expect( example_tree.fetch_path [:foo, :bar] ).to eql Sycamore::Tree[:baz]
      end

      it 'does behave like fetch, when no child tree at the given path present' do
        expect { example_tree.fetch_path [:missing_node, :foo]       }.to raise_error KeyError, /missing_node/
        expect { example_tree.fetch_path [:foo, :missing_node, :baz] }.to raise_error KeyError, /missing_node/
        expect { example_tree.fetch_path [:foo, :bar, :missing_node] }.to raise_error KeyError, /missing_node/
        expect { example_tree.fetch_path [:foo, :bar, :baz]     }.to raise_error Sycamore::ChildError, 'node :baz has no child tree'

        expect( example_tree.fetch_path([:missing, :foo      ], :default)    ).to be :default
        expect( example_tree.fetch_path([:foo, :missing, :baz]) { :default } ).to be :default
        expect( example_tree.fetch_path([:foo, :bar, :missing], :default)    ).to be :default
        expect( example_tree.fetch_path([:foo, :bar, :baz]) { :default }     ).to be :default
      end
    end

    context 'when given a nodes path as a Sycamore::Path' do
      it 'does return the child tree of the node at the given given path, when present' do
        expect( example_tree.fetch_path Sycamore::Path[:foo]       ).to eql Sycamore::Tree[bar: :baz]
        expect( example_tree.fetch_path Sycamore::Path[:foo, :bar] ).to eql Sycamore::Tree[:baz]
      end

      it 'does behave like fetch, when no child tree at the given path present' do
        expect { example_tree.fetch_path Sycamore::Path[:missing_node, :foo]       }.to raise_error KeyError, /missing_node/
        expect { example_tree.fetch_path Sycamore::Path[:foo, :missing_node, :baz] }.to raise_error KeyError, /missing_node/
        expect { example_tree.fetch_path Sycamore::Path[:foo, :bar, :missing_node] }.to raise_error KeyError, /missing_node/
        expect { example_tree.fetch_path Sycamore::Path[:foo, :bar, :baz]     }.to raise_error Sycamore::ChildError, 'node :baz has no child tree'

        expect( example_tree.fetch_path(Sycamore::Path[:missing, :foo      ], :default)    ).to be :default
        expect( example_tree.fetch_path(Sycamore::Path[:foo, :missing, :baz]) { :default } ).to be :default
        expect( example_tree.fetch_path(Sycamore::Path[:foo, :bar, :missing], :default)    ).to be :default
        expect( example_tree.fetch_path(Sycamore::Path[:foo, :bar, :baz]) { :default }     ).to be :default
      end
    end

    context 'edge cases' do
      it 'raises an error, when given no arguments' do
        expect { example_tree.fetch_path }.to raise_error ArgumentError
      end

      it 'does return the tree itself, when the given path is empty' do
        expect( example_tree.fetch_path [] ).to be example_tree
        expect( example_tree.fetch_path Sycamore::Path[] ).to be example_tree
      end
    end
  end

  ############################################################################

  describe '#search' do
    context 'when given a single node' do
      it 'does return an empty array, when the given node is not present in the tree or any of its child trees' do
        expect( Sycamore::Tree.new.search(1) ).to be_an(Array).and be_empty
        expect( Sycamore::Tree[foo: '1'].search(1) ).to be_an(Array).and be_empty
      end

      it 'does return the root path, when the given node is present in the node set directly' do
        expect( Sycamore::Tree[1,2,3].search(2) ).to contain_exactly Sycamore::Path::ROOT
      end

      it 'does return all paths to the child trees, where the given node is in the node set' do
        expect( Sycamore::Tree[foo: :bar].search(:bar) ).to contain_exactly Sycamore::Path[:foo]
        expect( Sycamore::Tree[1 => {2 => [3, 42], 42 => 4}].search(42) )
          .to contain_exactly Sycamore::Path[1, 2], Sycamore::Path[1]
      end

      it 'does return every path to the child trees, even when the given node is multiple times present on the path' do
        expect( Sycamore::Tree[foo: {foo: :foo}].search(:foo) )
          .to contain_exactly Sycamore::Path[], Sycamore::Path[:foo], Sycamore::Path[:foo, :foo]
      end
    end

    context 'when given an enumerable collection of nodes' do
      it 'does return an empty array, when all of the given nodes are not present in the tree or any of its child trees' do
        expect( Sycamore::Tree[1].search([1,2]) ).to be_an(Array).and be_empty
        expect( Sycamore::Tree[foo: :bar].search([:foo, :bar]) ).to be_an(Array).and be_empty
      end

      it 'does return the root path, when the given nodes are present in the node set directly' do
        expect( Sycamore::Tree[1,2,3].search([1, 2]) ).to contain_exactly Sycamore::Path::ROOT
      end

      it 'does return all paths to the child trees, where the given nodes are in the node set' do
        expect( Sycamore::Tree[foo: [:bar, :baz]].search([:bar, :baz]) ).to contain_exactly Sycamore::Path[:foo]
        expect( Sycamore::Tree[1 => {2 => [3, :foo, :bar], 4 => [:foo, :bar]}].search([:foo, :bar]) )
          .to contain_exactly Sycamore::Path[1, 2], Sycamore::Path[1, 4]
      end

      it 'does return every path to the child trees, even when the given nodes are multiple times present on the path' do
        expect( Sycamore::Tree[foo: {foo: [:foo, :bar]}, bar: nil].search([:foo, :bar]) )
          .to contain_exactly Sycamore::Path[], Sycamore::Path[:foo, :foo]
      end
    end

    context 'when given a tree-like structure' do
      it 'does return an empty array, when all the given tree structure is not present in the tree or any of its child trees' do
        expect( Sycamore::Tree[1].search(foo: :bar) ).to be_an(Array).and be_empty
        expect( Sycamore::Tree[foo: :bar].search(foo: :baz) ).to be_an(Array).and be_empty
      end

      it 'does return the root path, when the given tree structure is present directly' do
        expect( Sycamore::Tree[foo: :bar].search(foo: :bar) ).to contain_exactly Sycamore::Path::ROOT
      end

      it 'does return all paths to the child trees, where the given tree structure is present' do
        expect( Sycamore::Tree[1 => {foo: [:bar, :baz]}].search(foo: :bar) ).to contain_exactly Sycamore::Path[1]
        expect( Sycamore::Tree[1 => {2 => {3 => nil, foo: :bar}, 4 => {foo: :bar}}].search(foo: :bar) )
          .to contain_exactly Sycamore::Path[1, 2], Sycamore::Path[1, 4]
      end

      it 'does return every path to the child trees, even when the given tree structure is multiple times present on the path' do
        expect( Sycamore::Tree[foo: {foo: {foo: :bar}, bar: nil}].search(foo: :bar) )
          .to contain_exactly Sycamore::Path[], Sycamore::Path[:foo, :foo]
      end
    end
  end

end
