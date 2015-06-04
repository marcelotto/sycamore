describe Sycamore::Tree do

  ################################################################
  # creation                                                     #
  ################################################################

  describe '#initialize' do

    context 'when called via an unqualified Tree.new' do

      context "before requiring 'sycamore/extension'" do
        it 'raises a NameError' do
          expect { Tree.new }.to raise_error NameError
        end
      end

      context "after requiring 'sycamore/extension'" do
        before {
          # TODO: "We must ensure it's not required yet"
          require 'sycamore/extension' }
        it 'creates a Tree' do
          expect( Tree.new ).to be_a Sycamore::Tree
        end
      end
    end

    context 'when called with an unqualified Tree()' do

      context "before require 'sycamore/extension'" do
        it 'raises NoMethodError' do
          pending "We must ensure sycamore/extension is not required yet!"
          expect { Tree() }.to raise_error NoMethodError
        end
      end

      context "after require 'sycamore/extension'" do
        before(:all) { require 'sycamore/extension' }
        it 'creates a Tree' do
          expect( Tree() ).to be_a Sycamore::Tree
        end
      end

    end

    context 'when no initial nodes and/or a block given' do
      specify { expect( Tree() ).to be_a Sycamore::Tree }
      specify { expect( Tree() ).to be_empty }
    end

    context 'when arguments and/or a block given' do

      context 'when a single initial atom value given' do
        specify { expect( Tree(42) ).to include_node_with 42 }
      end

      context 'when a single Enumerable given' do
        let(:enumerable) { [number, string, symbol] }
        specify { expect( Tree(enumerable) ).to include_nodes_with enumerable }
      end

      context 'when multiple atom values given' do
        it 'raises an ArgumentError' do
          expect { Tree(:foo, :bar, :baz) }.to raise_error ArgumentError
        end
      end

      context 'when additional arguments given' do
        context 'when named argument nodes given?'
        context 'when named argument ... given'
      end

    end

  end


  ################################################################
  # Tree factory functions
  #
  # TODO: Extract this into a shared example group used by all factory spec!
  ################################################################

  describe '.[]' do

    context 'when no args given' do
      subject { Tree[] }
      it { is_expected.to be_a Sycamore::Tree }
      it { is_expected.to be_empty }
    end

    context 'when one argument given' do
      subject { Tree[1] }
      it { is_expected.to be_a Sycamore::Tree }
      it { is_expected.not_to be_empty }
      it { is_expected.to include 1 }
    end

    context 'when multiple arguments given' do
      subject { Tree[1, 2, 3] }
      it { is_expected.to be_a Sycamore::Tree }
      it { is_expected.not_to be_empty }
      it { is_expected.to include 1 }
      it { is_expected.to include 2 }
    end

    context 'when hash arguments given' do
      subject { Tree[a: 1, b: 2] }
      it { is_expected.to be_a Sycamore::Tree }
      it { is_expected.not_to be_empty }
      it { is_expected.to include :a }
      it { is_expected.to include :b }
    end
  end


  describe '.from' do

    context 'when no initial values or named arguments or a block given' do
      subject { Tree.from() }
      it { is_expected.to be_a Sycamore::Tree }
      it { is_expected.to be Sycamore::Nothing }
    end

    context 'when initial nil values given and no block given' do
      subject { Tree.from(nil) }
      it { is_expected.to be_a Sycamore::Tree }
      it { is_expected.to be Sycamore::Nothing }
    end

    context 'when only a block given' do
      subject { skip 'Tree#initialize with block' ; Tree.from { |args|  } }
      it { is_expected.to be_a Sycamore::Tree }
      it { is_expected.not_to be Sycamore::Nothing }
    end

    context 'when initial values or named arguments given' do
      subject { Tree.from [1, 2, 3] }
      it { is_expected.to be_a Sycamore::Tree }
      it { is_expected.not_to be Sycamore::Nothing }
    end

  end

  describe '.from!' do

    context 'when no initial values or named arguments and no block given' do
      it 'raises an ArgumentError' do
        expect { Tree.from!() }.to raise_error ArgumentError
      end
    end

    context 'when initial nil values and no block given' do
      it 'raises an ArgumentError' do
        expect { Tree.from!(nil) }.to raise_error ArgumentError
      end
    end

    context 'when only a block given' do
      subject { skip 'Tree#initialize with block' ; Tree.from! { |args|  } }
      it { is_expected.to be_a Sycamore::Tree }
      it { is_expected.not_to be Sycamore::Nothing }
    end

    context 'when initial values or named arguments given' do
      subject { Tree.from! [1, 2, 3] }
      it { is_expected.to be_a Sycamore::Tree }
      it { is_expected.not_to be Sycamore::Nothing }
    end

  end


  ################################################################
  # general nodes and children API                               #
  ################################################################

  #####################
  #  query interface  #
  #####################

  describe '#empty?' do

    it 'does return true, when the Tree has no nodes' do
      expect(Tree().empty?).to be_truthy
      expect(Tree().empty?).to be true
      expect(Tree(nil).empty?).to be true
      expect(Tree([nil]).empty?).to be true
      expect(Tree(Sycamore::Nothing).empty?).to be true
      expect(Tree([Sycamore::Nothing]).empty?).to be true
    end

    it 'does return false, when the Tree has nodes' do
      expect(Tree(42).empty?).to be_falsey
      expect(Tree(42).empty?).to be false
      expect(Tree([42]).empty?).to be false
      expect(Tree(property: :value).empty?).to be false
    end

  end

  describe '#include?' do

    context 'when given an atom' do
      context 'when the atom is in the node set' do
        specify { expect( Tree(1) ).to include 1 }
        specify { expect( Tree([42, another_string]) ).to include 42 }
        specify { expect( Tree(property: string) ).to include :property }

        specify { expect( Tree[0].include? 0 ).to be true }
        specify { expect( Tree[''].include? '' ).to be true }
        specify { expect( Tree[1,2].include? 1 ).to be true }
        specify { expect( Tree[1,2].include? 2 ).to be true }
      end

      context 'when the atom is not in the node set' do
        specify { expect( Tree[] ).to_not include number }
        specify { expect( Tree[1].include? 2 ).to be false }
        specify { expect( Tree[1,2].include? [1, 3] ).to be false }
      end

    end

    context 'when given an array, as a single Enumerable' do
      context 'when all elements are in the node set' do
        specify { expect( Tree[1, 2].include? [1] ).to be true }
        specify { expect( Tree[1, 2].include? [1, 2] ).to be true }
        specify { expect( Tree[1, 2].include? [2, 1] ).to be true }
        specify { expect( Tree[1, 2, 3].include? [1, 2] ).to be true }
        specify { expect( Tree([:foo, :bar, :baz]).include? [:baz, :foo] ).to be true }
      end

      context 'when none of its elements is in the node set' do
        specify { expect( Tree[].include? [1] ).to be false }
        specify { expect( Tree[1, 2].include? [3] ).to be false }
      end

      context 'when some elements are not in the node set' do
        specify { expect( Tree[:foo, :bar, :baz].include? [:foo, :bar, 1] ).to be false }
        specify { expect( Tree[1, 2].include? [1, 3] ).to be false }
      end

    end


    context 'when given a hash' do

      context 'when a matching tree structure of nodes with equally structured values' do
        context 'hash contains one key-value-pair' do
          specify { expect( Tree[1 => 2].include?(1 => 2) ).to be true }
          specify { expect( Tree[1 => 2].include?(1 => nil) ).to be true }
          specify { expect( Tree[1 => 2].include?(1 => Sycamore::Nothing) ).to be true }
          specify { expect( Tree[1 => 2].include?(1 => { 2 => nil }) ).to be true }
          specify { expect( Tree[1 => 2].include?(1 => { 2 => Sycamore::Nothing }) ).to be true }
          specify { expect( Tree[1 => [2, 3]].include?(1 => 2) ).to be true }
          specify { expect( Tree[1 => 2, 3 => 1].include?(1 => 2) ).to be true }
        end

        context 'hash contains multiple key-value-pairs' do
          specify { expect( Tree[1 => 2, 3 => 1].include?(1 => 2, 3 => 1) ).to be true }
          specify { expect( Tree[1 => [2, 3], 3 => 1].include?(1 => 2, 3 => 1) ).to be true }
          specify { expect( Tree[1 => [2, 3], 3 => 1].include?(1 => 2, 3 => nil) ).to be true }
          specify { expect( Tree[1 => [2, 3], 3 => 1].include?(1 => 2, 3 => Sycamore::Nothing) ).to be true }
        end
      end

      context 'when only partially matching tree structure of nodes with equally structured values' do
        specify { expect( Tree[1].include?(1 => 2) ).to be false }
        specify { expect( Tree[1 => 2].include?(1 => [2, 3]) ).to be false }
        specify { expect( Tree[1 => 2].include?(1 => 2, 3 => 1) ).to be false }
      end

      context 'when no matching tree structure of nodes with equally structured values' do
        specify { expect( Tree[].include?(1 => 2) ).to be false }
        specify { expect( Tree[42 => 2].include?(1 => 2) ).to be false }
      end

    end

    context 'when given another Tree' do
      pending '#include? with another Tree' # TODO: Should we duplicate all of above specs (for atom, array, hash) with the args converted to a Tree?
      # specify { expect( Tree[1,2].include? Tree[1] ).to be true }
      # specify { expect( Tree[1,2].include? Tree[2] ).to be true }
      # specify { expect( Tree[1,2].include? Tree[1] ).to be true }
      # specify { expect( Tree[1,2].include? Tree[1, 2] ).to be true }
      # specify { expect( Tree[1,2].include? Tree[1, 3] ).to be false }
    end

  end

  describe '#size' do

    context 'when empty' do
      specify { expect( Tree[].size ).to be 0 }
    end

    context 'when having one leaf' do
      specify { expect( Tree[number].size ).to be 1 }
    end

    context 'when having more leaves' do
      specify { expect( Tree[symbol, number, string].size ).to be 3 }
    end

    context 'when having nodes with children' do
      specify { expect( Tree[a: 1, b: nil].size ).to be 2 }
    end
  end


  #####################
  # command interface #
  #####################

  describe '#add' do

    context 'when a single initial atom value argument given' do
      let(:atom) { number }
      subject { Tree[] << atom }
      it { is_expected.to include_node_with atom }
    end

    context 'when a single Enumerable argument given' do
      let(:enumerable) { [symbol, number, string] }
      subject { Tree[] << enumerable }
      it { is_expected.to include_nodes_with enumerable }
    end

    context 'when a tree-like structure given' do
      let(:tree) { { symbol => number } }
      subject { Tree[] << tree }
      it { is_expected.to include_tree_with tree }
    end

    context 'when multiple atom value arguments given' do
      let(:enumerable) { [symbol, number, string] }
      subject { Tree[].add(*enumerable) }
      it { pending 'Can/should we support multiple argument initializations here?' ; is_expected.to include_nodes_with enumerable }
    end

  end


  describe '#remove' do
    pending
  end


  describe '#clear' do

    context 'when empty' do
      subject(:empty_tree) { Tree[] }
      specify { expect { empty_tree.clear }.not_to change(empty_tree, :size) }
      specify { expect { empty_tree.clear }.not_to change(empty_tree, :nodes) }
    end

    context 'when not empty' do
      let(:nodes) { [42, :foo] }
      subject { Tree[nodes].clear }

      it { is_expected.to be_empty }

      it 'does remove all nodes' do
        nodes.each do |node|
          expect(subject).not_to include(node)
        end
      end
    end

  end


  ################################################################
  # Nodes API                                                    #
  ################################################################

  #####################
  #  query interface  #
  #####################

  describe '#nodes' do

    shared_examples 'result invariants' do
      it { is_expected.to be_an Enumerable }
      it { is_expected.to be_an Array } # ; TODO: skip 'Should we expect nodes to return an Array? Why?' }
    end

    context 'when empty' do
      subject { Sycamore::Tree[].nodes }
      include_examples 'result invariants'
      it { is_expected.to be_empty }
    end

    context 'when containing a single leaf node' do
      let(:atom) { symbol }
      subject { Sycamore::Tree[atom].nodes }
      include_examples 'result invariants'
      it { is_expected.to contain_exactly atom }
    end

    context 'when containing multiple nodes' do

      context 'without children, only leaves' do
        let(:leaves) { [:foo, :bar, :baz] }
        subject(:nodes) { Sycamore::Tree[leaves].nodes }
        include_examples 'result invariants'

        it 'does return the nodes unordered' do
          expect(nodes.to_set).to eq leaves.to_set
        end

        specify { expect(Tree[:foo, :bar, :baz, :foo, :bar, :baz].nodes.to_set).to eq leaves.to_set }
        specify { expect(Tree['foo', 'bar', 'baz', 'foo', 'bar'].nodes.to_set).to eq Set['foo', 'bar', 'baz'] }
      end

      context 'with children' do
        let(:tree) { { foo: 1, bar: 2, baz: nil } }
        subject(:nodes) { Sycamore::Tree[tree].nodes }
        include_examples 'result invariants'

        specify { expect(nodes.to_set).to eq tree.keys.to_set }
      end

    end

    context 'when another depth than the default 0 given' do
      it 'does merge the nodes of all children down to the given tree depth'
    end

  end


  #####################
  # command interface #
  #####################

  describe '#add_node' do

    context 'when given nil' do
      subject { Tree[].add_node(nil) }
      it { is_expected.to be_empty }
    end

    context 'when given Nothing' do
      subject { Tree[].add_node(Sycamore::Nothing) }
      it { is_expected.to be_empty }
    end

    context 'when given a single atom' do
      context 'when a node for this atom not exists' do
        specify { expect(Tree[].add_node(:a)).to include_node_with(:a) }
      end

      context 'when a node for this atom exists' do
        specify { expect(Tree[a: 1].add_node(:a)).to include_tree_with(a: 1) }
      end
    end

    context 'when given an Enumerable' do
      # @todo https://www.pivotaltracker.com/story/show/94733228
      #   Do we really need this? If so, document the reasons!
      it 'raises an error' do
        expect { Tree.new.add_node([1, 2]) }.to raise_error(Sycamore::NestedNodeSet)
      end
    end

  end


  describe '#add_nodes' do

    context 'when given nil' do
      subject { Tree[].add_nodes(nil) }
      it { is_expected.to be_empty }
    end

    context 'when given multiple nils' do
      subject { Tree[].add_nodes(nil, nil, nil) }
      it { is_expected.to be_empty }
    end

    context 'when given nils and non-nil atoms' do
      subject { Tree[].add_nodes(nil, :foo, nil) }
      it { is_expected.not_to be_empty }
      it { is_expected.to include_node_with :foo }
      it { expect(subject.size).to be 1 }
    end

    context 'when given Nothing' do
      subject { Tree[].add_nodes(Sycamore::Nothing) }
      it { is_expected.to be_empty }
      it { skip 'is_expected.not_to be_a Absence' }
    end

    context 'when given a single atom' do
      context 'when the node not exists in the tree' do
        specify { expect(Tree[].add_nodes(:a)).to include_nodes_with(:a) }
      end

      context 'when the node already exists in the tree' do
        specify { expect(Tree[a: 1].add_nodes(:a)).to include_tree_with(a: 1) }
      end
    end

    context 'when given multiple atoms' do
      let(:enumerable) { [symbol, number, string] }
      subject { Tree.new.add_nodes(*enumerable) }
      it { is_expected.to include_nodes_with enumerable }

      specify { expect(Tree.new) }

    end

    context 'when given multiple Enumerables' do
      # @todo https://www.pivotaltracker.com/story/show/94733228
      #   Do we really need this? If so, document the reasons!
      it 'does raise an error' do
        expect { Tree.new.add_nodes([1, [2, 3]]) }. to raise_error(Sycamore::NestedNodeSet)
      end
    end

    context 'when given a single Enumerable' do
      let(:enumerable) { [symbol, number, string] }
      subject { Tree.new.add_nodes(enumerable) }
      it { is_expected.to include_nodes_with enumerable }
    end

  end


  describe '#remove_node' do

    context 'when the given node is in this tree' do
      let(:nodes) { [42, :foo] }
      subject(:tree) { Tree[nodes].remove_node(42) }

      it { is_expected.not_to include 42 }
      it { is_expected.to include :foo }

      it 'does decrease the size' do
        expect(tree.size).to be nodes.size - 1
      end
    end

    context 'when the given node is not in this tree' do
      let(:initial_nodes) { [:foo] }
      subject(:tree) { Tree[initial_nodes].remove_node(42) }

      it { is_expected.not_to include 42 }
      it { is_expected.to include :foo }

      it 'does not decrease the size' do
        expect(tree.size).to be initial_nodes.size
      end
    end

  end


  describe '#remove_nodes' do
    pending
  end



  ################################################################
  # Children API                                                 #
  ################################################################

  #####################
  #  query interface  #
  #####################

  describe '#child' do

    context 'when given a single atom' do

      context 'when the given atom is nil' do
        specify { expect(Tree()[nil]).to be Sycamore::Nothing }
        # TODO when Absence defined: specify { expect(Tree[nil]).not_to be_a Absence }
      end

      context 'when the given atom is Nothing' do
        specify { expect(Tree()[Sycamore::Nothing]).to be Sycamore::Nothing }
      end

      context 'when a corresponding node is present' do

        context 'when the node has a child' do
          let(:root) { Sycamore::Tree.new.add_child(:property, :value) }
          let(:child) { root[:property] }

          describe 'root' do
            subject { root }
            it { is_expected.to include :property }
            it { is_expected.not_to include :value }
          end

          describe 'child' do
            subject { child }
            it { is_expected.to be_a Sycamore::Tree }
            it { is_expected.to_not be Sycamore::Nothing }
            it { is_expected.to include :value }
            it { is_expected.not_to include :property }
          end
        end

        context 'when the node is a leaf' do
          let(:root) { Sycamore::Tree(42) }
          let(:child) { root.child(42) }

          # TODO: Really the same behaviour as when node absent?

          it 'does return an Absence' do
            skip 'Absence'
          end

          describe 'root' do
            subject { root }
            it { is_expected.to include 42 }
          end

          describe 'child' do
            subject { child }
            it { is_expected.to be_a Sycamore::Tree }
            it { is_expected.to be Sycamore::Nothing }
          end

        end
      end

      context 'when a corresponding node is absent' do
        let(:root) { Sycamore::Tree() }
        let(:child) { root[:property] }

        # TODO: Really the same behaviour as when node is a leaf?

        it 'does return an Absence' do
          skip 'Absence'
        end

        describe 'root' do
          subject { root }
          it { is_expected.to be_empty }
        end

        describe 'child' do
          subject { child }
          it { is_expected.to be_a Sycamore::Tree }
          it { is_expected.to be Sycamore::Nothing }
        end

      end

    end

  end


  describe '#leaf?' do

    context 'when given a single atom' do

      # see #leaf?

      context 'when the given atom is nil' do
        specify { expect( Tree[].leaf?(nil) ).to be false }
      end

      context 'when the given atom is Nothing' do
        specify { expect(Tree[].leaf?(Sycamore::Nothing)).to be false }
      end

      context 'when the corresponding node is present' do

        context 'when the corresponding node is a leaf' do
          specify { expect(Tree[1].leaf?(1)).to be true }
          specify { expect(Tree[1 => nil].leaf?(1)).to be true }
          specify { expect(Tree[1 => Sycamore::Nothing].leaf?(1)).to be true }
          specify { expect(Tree[1 => :foo, 2 => nil].leaf?(2)).to be true }
        end

        context 'when the corresponding node has a child' do
          specify { expect(Tree[1 => :foo].leaf?(1)).to be false }
          specify { expect(Tree[1 => :foo, 2 => nil].leaf?(1)).to be false }
        end

        context 'when the corresponding node has a child, but it is empty' do
          specify do
            tree = Tree[1 => :foo]
            tree[1].clear
            expect(tree.leaf?(1)).to be true
          end

          specify do
            tree = Tree[1 => :foo, 2 => nil]
            tree[1].clear
            expect(tree.leaf?(1)).to be true
          end
        end

      end

      context 'when the corresponding node is absent' do
        specify { expect(Tree().leaf?(42)).to be false }
        specify { expect(Tree[43].leaf?(42)).to be false }
      end

    end

  end


  describe '#leaves?' do

    context 'without arguments' do
      context 'when all nodes are leaves' do
        specify { expect(Tree[]).to be_leaves }
        specify { expect(Tree[1]).to be_leaves }
        specify { expect(Tree[1 => nil]).to be_leaves }
        specify { expect(Tree[1 => Sycamore::Nothing]).to be_leaves }
        specify { expect(Tree[1, 2, 3]).to be_leaves }
      end

      context 'when some nodes are not leaves' do
        specify { expect(Tree[1 => 2]).not_to be_leaves }
        specify { expect(Tree[1 => :a, 2 => nil, 3 => nil]).not_to be_leaves }
        specify { expect(Tree[1 => :a, 2 => Sycamore::Nothing, 3 => Sycamore::Nothing]).not_to be_leaves }
      end
    end

    context 'when given a single atom' do
      # see #leaf?
    end

    context 'when given an Enumerable (by one enumerable argument or multiple atomic arguments)' do

      context 'when all corresponding nodes of the Enumerable are present and leafs' do
        specify { expect(Tree[1,2,3].leaves?([1,2,3])).to be true }
        specify { expect(Tree[1,2,3].leaves?(1,2,3)).to be true }
        specify { expect(Tree[1 => nil, 2 => nil, 3 => nil].leaves?(1,2,3)).to be true }
      end

      context 'when all corresponding nodes of the Enumerable are present, but some have a child' do
        specify { expect(Tree[1 => :a, 2 => nil, 3 => nil].leaves?([1,2,3])).to be false }
      end

      context 'when some corresponding nodes of the Enumerable are absent or have a child' do
        specify { expect(Tree[1,2].leaves?(1,2,3)).to be false }
        specify { expect(Tree[1 => :a, 2 => nil].leaves?(1,2)).to be false }
        specify { expect(Tree[].leaves?(1,2,3)).to be false }
      end

    end


    context 'when given something Tree.like' do
      it 'raises an ArgumentError' do
        expect { Tree().leaves?(a: 1) }.to raise_error ArgumentError
      end
    end

  end



  #####################
  # command interface #
  #####################

=begin
  context 'when a corresponding node is present'

  context 'when the node has a child'

=end

  describe '#add_child' do

    context 'when the given node is nil' do
      subject { Tree[].add_child(nil, 42) }
      it      { is_expected.to be_empty }
      # TODO when Absence defined: it { is_expected.not_to be_a Absence }
    end

    context 'when the given node is Nothing' do
      subject { Tree[].add_child(Sycamore::Nothing, 42) }
      it      { is_expected.to be_empty }
      # TODO when Absence defined: it { is_expected.not_to be_a Absence }
    end


    ###############
    # TODO: Refactor the following

    specify 'some examples for atoms' do
      tree = Sycamore::Tree.new

      tree.add_child(42, 3.14) # => {1 => 3.14}
      expect(tree).to include 42
      expect(tree.size).to be 1
      expect(tree.child(42)).to be_a Tree
      expect(tree.child(42)).not_to be Sycamore::Nothing
      expect(tree.child(42)).to include 3.14
      expect(tree.child(42).size).to be 1

      tree.add_child(42, 'text') # => {1 => [3.14, 'text']}
      expect(tree.size).to be 1
      expect(tree.child(42)).to include 'text'
      expect(tree.child(42).size).to be 2

      tree.add_child(1, nil)
      tree.add_child(42, Sycamore::Nothing) # => {1 => [3.14, 'text']}
      expect(tree.size).to be 2
      expect(tree.child(42).size).to be 2

    end


    specify 'some examples for arrays' do
      tree = Sycamore::Tree.new

      tree.add_child(:root, [2, 3]) # => {:root => [2, 3]}
      expect(tree).to include :root
      expect(tree.size).to be 1
      expect(tree.child(:root)).to be_a Sycamore::Tree
      expect(tree.child(:root)).not_to be Sycamore::Nothing
      expect(tree.child(:root)).to include 2
      expect(tree.child(:root)).to include 3
      # TODO: expect(tree.child(:root)).to include [2,3]
      expect(tree.child(:root).size).to be 2

      tree.add_child(:root, [3, 4, 0]) # => {:root => [2, 3, 4, 0]}
      expect(tree.size).to be 1
      expect(tree.child(:root)).to include 4
      expect(tree.child(:root)).to include 0
      # TODO: expect(tree.child(:root)).to include [3, 4]
      expect(tree.child(:root).size).to be 4

      tree.add_child(:root, []) # => {:root => [2, 3, 4, 0]}
      expect(tree.size).to be 1
      expect(tree.child(:root)).to include 4
      expect(tree.child(:root)).to include 0
      expect(tree.child(:root).size).to be 4

    end

    specify 'some examples for hashes' do
      tree = Sycamore::Tree.new

      tree.add_child(:noah, {shem: :elam } ) # => {:noah => {:shem => :elam}}
      expect(tree).to include :noah
      expect(tree.size).to be 1
      expect(tree.child(:noah)).to be_a Sycamore::Tree
      expect(tree.child(:noah)).not_to be Sycamore::Nothing
      expect(tree.child(:noah)).to include :shem
      expect(tree.child(:noah).size).to be 1
      expect(tree.child(:noah).child(:shem)).to be_a Sycamore::Tree
      expect(tree.child(:noah).child(:shem)).not_to be Sycamore::Nothing
      expect(tree.child(:noah).child(:shem)).to include :elam
      expect(tree.child(:noah).child(:shem).size).to be 1

      tree.add_child(:noah, {shem: :asshur,
                             japeth: :gomer,
                             ham: [:cush, :mizraim, :put, :canaan] } )
      # => {:noah => {:shem   => [:elam, :asshur]}
      #              {:japeth => :gomer}
      #              {:ham    => [:cush, :mizraim, :put, :canaan]}}
      expect(tree.size).to be 1
      expect(tree[:noah].size).to be 3
      expect(tree[:noah]).to include :japeth
      expect(tree[:noah]).to include :ham
      expect(tree[:noah][:shem].size).to be 2
      expect(tree[:noah][:shem]).to include :elam
      expect(tree[:noah][:shem]).to include :asshur
      expect(tree[:noah][:japeth].size).to be 1
      expect(tree[:noah][:japeth]).to include :gomer
      expect(tree[:noah][:ham].size).to be 4
      expect(tree[:noah][:ham]).to include :cush
      expect(tree[:noah][:ham]).to include :mizraim
      expect(tree[:noah][:ham]).to include :put
      expect(tree[:noah][:ham]).to include :canaan

      tree << { noah: {shem: :asshur,
                             japeth: :gomer,
                             ham: [:cush, :mizraim, :put, :canaan] } }
      # => {:noah => {:shem   => [:elam, :asshur]}
      #              {:japeth => :gomer}
      #              {:ham    => [:cush, :mizraim, :put, :canaan]}}
      expect(tree.size).to be 1
      expect(tree[:noah].size).to be 3
      expect(tree[:noah]).to include :japeth
      expect(tree[:noah]).to include :ham
      expect(tree[:noah][:shem].size).to be 2
      expect(tree[:noah][:shem]).to include :elam
      expect(tree[:noah][:shem]).to include :asshur
      expect(tree[:noah][:japeth].size).to be 1
      expect(tree[:noah][:japeth]).to include :gomer
      expect(tree[:noah][:ham].size).to be 4
      expect(tree[:noah][:ham]).to include :cush
      expect(tree[:noah][:ham]).to include :mizraim
      expect(tree[:noah][:ham]).to include :put
      expect(tree[:noah][:ham]).to include :canaan

      tree.add_child(:noah, {})
      # => {:noah => {:shem   => [:elam, :asshur]}
      #              {:japeth => :gomer}
      #              {:ham    => [:cush, :mizraim, :put, :canaan]}}
      expect(tree.size).to be 1
      expect(tree.child(:noah).size).to be 3
      expect(tree.child(:noah).child(:shem).size).to be 2
      expect(tree.child(:noah).child(:japeth).size).to be 1
      expect(tree.child(:noah).child(:ham).size).to be 4

    end

    specify 'some examples for Trees' do
      tree = Sycamore::Tree.new

    end

=begin
    shared_examples 'for adding a given Atom-like child' do |options = {}|
      let(:initial) { options[:initial] or raise ArgumentError, 'No initial value given.' }
      let(:node)    { options[:node]    or raise ArgumentError, 'No node given.' }
      let(:child)   { options[:child]   or raise ArgumentError, 'No child given.' }

      # TODO: extract from below - Problem: no access to initial, nodes etc.
      # describe 'the added tree' do
      #   subject(:added_child) { tree_with_child.child(node) }
      #   it { is_expected.to be_a Tree }
      #   it { is_expected.to_not be Sycamore::Nothing }
      #   it { is_expected.to_not be tree_with_child }
      #   it { is_expected.to include child }
      #   it 'does add only the nodes of the given child, to the child of the new child tree' do
      #     expect(added_child.size).to be 1
      #   end
      # end
    end

    shared_examples 'for adding a given Collection-like child' do
    end

    shared_examples 'for adding a given Tree-like child' do
    end
=end

    subject(:tree) { Sycamore::Tree.new(initial) }

    let(:tree_with_child) { tree.add_child(node, child) }

    context 'when the given node is present' do

      context 'when the node does not have already child' do

        context 'when given an Atom-like child' do
          let(:initial) { [1] }
          let(:node)    { 1 }
          let(:child)   { 2 }


          # TODO: extract the general addition examples, independent from the state
          #         into a custom matcher
          # include_examples 'for adding a given Atom-like child',
          #                  initial: [1], node: 1, child: 2


          it { is_expected.to include node }

          describe 'the added tree' do
            subject(:added_child) { tree_with_child.child(node) }
            it { is_expected.to be_a Tree }
            it { is_expected.to_not be Sycamore::Nothing }
            it { is_expected.to include child }
            it 'does add only the nodes of the given child, to the child of the new child tree' do
              expect(added_child.size).to be 1
            end
          end

        end

        context 'when the node has already a child' do

          context 'when given an Atom-like child' do
            # include_examples 'for adding a given Atom-like child'
          end
          context 'when given a Collection-like child' do
            # include_examples 'for adding a given Collection-like child'
          end
          context 'when given a Tree-like child' do
            # include_examples 'for adding a given Tree-like child'
          end
        end


        context 'when given a Collection-like child' do
          # include_examples 'for adding a given Collection-like child'
        end
        context 'when given a Tree-like child' do
          # include_examples 'for adding a given Tree-like child'
        end
      end

    end

    context 'when a node to the given atom is absent' do

    end

    context 'when the given atom is nil' do
      pending
    end

    context 'when the given atom is Nothing' do
      pending
    end


=begin
    context 'the given node is in the tree as a leaf' do
      let(:initial) { [1] }
      let(:node)    { 1 }
      let(:child)   { 2 }

      describe 'the added tree' do
        subject(:added_child) { tree_with_child.child(node) }
        it { is_expected.to be_a Tree }
        it { is_expected.to_not be Sycamore::Nothing }
        it { is_expected.to_not be tree_with_child }
        it { is_expected.to include child }
        it 'does add only the nodes of the given child, to the child of the new child tree' do
          expect(added_child.size).to be 1
        end
      end

    end
=end

    context 'the given node is not in the tree' do
      let(:initial) { [] }
      let(:node)    { 1 }
      let(:child)   { 2 }

      describe 'the added tree' do
        subject(:added_child) { tree_with_child.child(node) }
        it { is_expected.to be_a Tree }
        it { is_expected.to_not be Sycamore::Nothing }
        it { is_expected.to_not be tree_with_child }
        it { is_expected.to include child }
        it 'does add only the nodes of given the given child, to the child of the new child tree' do
          expect(added_child.size).to be 1
        end
      end
    end

    context 'when the given node is in this tree with an existing child tree' do
      let(:initial) { { 1 => 2 } }
      let(:node)    { 1 }
      let(:child)   { 3 }

      describe 'the added tree' do
        subject(:added_child) { tree_with_child.child(node) }

        it { is_expected.to be_a Tree }
        it { is_expected.to_not be Sycamore::Nothing }
        it { is_expected.to_not be tree_with_child } # TODO: Needed/Useful?
        it { is_expected.to include child }
        it { is_expected.to include 2 }

        it 'does add only the nodes of given the given child, to the child of the new child tree' do
          expect(added_child.size).to be 2
        end
      end
    end

  end


  describe '#add_children' do

=begin
    shared_examples 'when given a flat tree-like structure' do

      subject { Sycamore::Tree.new(initial).add_children(struct) }

      context 'when nodes for certain keys are already present, but are leaves' do
        let(:initial) { 1 }
        let(:struct)  { {1 => 2} }

        it 'creates a new tree, before adding the '
      end

      context 'when nodes for certain keys are not present' do
        let(:initial) { [] }
        let(:struct)  { {1 => 2} }

        it 'does add new nodes for keys of the struct, to which the value can be added as a child' do

        end
      end

      context 'when nodes for certain keys are already present and have children' do
        let(:initial) { {1 => 2} }
        let(:struct)  { {1 => 3} }
      end

    end
=end

    context 'when Nothing given' do
      subject { Tree[].add_children(Sycamore::Nothing) }
      it      { is_expected.to be_empty }
      # TODO when Absence defined: it { is_expected.not_to be_a Absence }
    end

    context 'when Absence given' do
    end

    context 'when given the empty hash' do
      subject { Tree[].add_children({}) }
      it      { is_expected.to be_empty }
    end

    specify { expect(Tree[a: 1]).to include(a: 1) }
    specify { expect(Tree[a: 1, b: 2]).to include(a: 1, b: 2) }
    specify { expect(Tree[a: 1, b: [2, 3]]).to include(a: 1, b: [2, 3]) }
    specify { expect(Tree[a: [1, 'foo'], b: {2 => 3}]).to include(a: [1, 'foo'], b: {2 => 3}) }

    specify { expect(Tree[1 => nil, 2 => nil, 3 => nil].leaves?(1,2,3)).to be true }
    specify { expect(Tree[1 => [], 2 => [], 3 => []].leaves?(1,2,3)).to be true }
    specify { expect(Tree[1 => {}, 2 => {}, 3 => {}].leaves?(1,2,3)).to be true }

  end


  ################################################################
  # Tree as an Enumerable                                        #
  ################################################################



  ################################################################
  # equality and equivalence
  #
  # look at:
  #
  # - Ruby's Set implementation
  # - equalizer: https://github.com/dkubb/equalizer
  #
  ################################################################

=begin
  describe '#hash' do
    specify { expect(Tree.new.hash   == Tree.new.hash).to be true }
    specify { expect(Tree[1].hash    == Tree[1].hash).to be true }
    specify { expect(Tree[1].hash    != Tree[2].hash).to be true }
    specify { expect(Tree[1,2].hash  == Tree[2,1].hash).to be true }
    specify { expect(Tree[a: 1].hash == Tree[a: 1].hash).to be true }
    specify { expect(Tree[a: 1].hash != Tree[a: 2].hash).to be true }
    specify { expect(Tree[a: 1].hash != Tree[b: 1].hash).to be true }
    specify { expect(Tree[1].hash    == Tree[1 => nil].hash).to be true }

    specify { expect(Tree.new.hash   != Hash.new.hash).to be true }
    specify { expect(Tree[a: 1].hash != Hash[a: 1].hash).to be true }
  end

  describe '#eql?' do
    # specify { expect(Tree.new).to eql Tree.new }
    # specify { expect(Tree[1]).to eql Tree[1] }
    specify { expect(Tree[1]).not_to eql Tree[2] }
    # specify { expect(Tree[1,2]).to eql Tree[2,1] }
    # specify { expect(Tree[a: 1]).to eql Tree[a: 1] }
    specify { expect(Tree[a: 1]).not_to eql Hash[a: 1] }
    specify { expect(Tree[1]).not_to eql Hash[1 => nil] }
  end

  describe '#==' do
    # specify { expect(Tree.new).to eq Tree.new }
    # specify { expect(Tree[1]).to eq Tree[1] }
    specify { expect(Tree[1]).not_to eq Tree[2] }
    # specify { expect(Tree[1,2]).to eq Tree[2,1] }
    # specify { expect(Tree[a: 1]).to eq Tree[a: 1] }
    specify { expect(Tree[a: 1]).not_to eq Hash[a: 1] }
    specify { expect(Tree[1]).not_to eq Hash[1 => nil] }

  end

  describe '#===' do
    specify { expect(Tree.new === Tree.new).to be true }
    specify { expect(Tree[1] === Tree[1]).to be true }
    specify { expect(Tree[1] === Tree[2]).to be false }
    specify { expect(Tree[1,2] === Tree[2,1]).to be true }
    specify { expect(Tree[a: 1] === Tree[a: 1]).to be true }
    specify { expect(Tree[a: 1] === Hash[a: 1]).to be false }
    specify { expect(Tree[1] === Hash[1 => nil]).to be false }

    # specify { expect(Tree.new).to eq Tree.new }
    # specify { expect(Tree[1]).to eq Tree[1] }
    # specify { expect(Tree[1]).not_to eq Tree[2] }
    # specify { expect(Tree[1,2]).to eq Tree[2,1] }
    # specify { expect(Tree[a: 1]).to eq Tree[a: 1] }
    # specify { expect(Tree[a: 1]).to eq Hash[a: 1] }
    # specify { expect(Tree[1]).to eq Hash[1 => nil] }
    # specify { expect(Tree[1]).to eq Hash[1 => Sycamore::Nothing] }
  end
=end



  ##########################################
  # comparison
  #
  # What should we support of this, since Tree probably doesn't have a total order?
  #
  # Should we map directly to include?, or should check if the other a Tree, i.e.
  #   should we support comparison on Tree.like? structures in general?
  #
  ##########################################

  describe '#<' do
    it 'does behave like include?, except it returns false when equal to the other'
    it 'delegates to #include? and #=== (negated)'
  end

  describe '#<=' do
    it 'delegates to #include?' do
      pending
      expect( Tree[1,2] <=       [1] ).to equal(
              Tree[1,2].include? [1])
      expect( Tree[1] <=         [1] ).to equal(
              Tree[1].include?   [1])
    end
  end

  describe '#>' do
    it 'delegates to #include? of the other and #=== (negated)'
  end

  describe '#>=' do
    it 'delegates to #include? of the other'
  end

  # describe '#<=>' do
  #   it 'delegates to #include? and #==='
  #   it 'is not supported, since Tree does not define a total order'
  # end



  ##########################################
  # conversion
  ##########################################

  # TODO: shared example or matcher for ...
  describe '#to_???' do
    specify { expect( Tree[         ].to_h ).to eq( {} ) }
    specify { expect( Tree[ 1       ].to_h ).to eq( 1 ) }
    specify { expect( Tree[ 1, 2, 3 ].to_h ).to eq( [1, 2, 3] ) }
    specify { expect( Tree[ :a => 1 ].to_h ).to eq( { :a => 1 } ) }
    specify { expect( Tree[ :a => 1, :b => [2, 3] ].to_h ).to eq(
                          { :a => 1, :b => [2, 3] } ) }
  end

  describe '#to_h' do
    pending
  end

  describe '#to_a' do

    # TODO: shared example or matcher for ...
    specify { expect( Tree[         ].to_a ).to eq( [] ) }
    specify { expect( Tree[ 1       ].to_a ).to eq( [1] ) }
    specify { expect( Tree[ 1, 2, 3 ].to_a ).to eq( [1, 2, 3] ) }
    specify { expect( Tree[ :a => 1 ].to_a ).to eq( [:a] ) }
    specify { expect( Tree[ :a => 1, :b => [2, 3] ].to_a ).to eq( [:a, :b] ) }
  end


  describe '#to_set' do # by nodes.to_set
    it "does require 'set'"
    it 'does delegate to Sets standard #to_set implementation'

  end


  describe '#to_s' do
    it 'delegates to the hash representation of #to_h'
    # TODO: shared example or matcher for ...

    specify { expect( Tree[         ].to_s ).to eq( '{}' ) }
    specify { expect( Tree[ 1       ].to_s ).to eq( '1' ) }
    specify { expect( Tree[ 1, 2, 3 ].to_s ).to eq( '[1, 2, 3]' ) }
    specify { expect( Tree[ :a => 1 ].to_s ).to eq( '{:a=>1}' ) }
    specify { expect( Tree[ :a => 1, :b => [2, 3] ].to_s ).to eq(
                          '{:a=>1, :b=>[2, 3]}' ) }

  end


  describe '#inspect' do
    it 'contains the hash representation' # from #to_h ???
  end



  ################################################################
  # Various other Ruby protocols                                 #
  ################################################################

  describe '#freeze' do

    it 'behaves Object#freeze conform' do
      # stolen from Ruby's tests of set.rb (test_freeze) adapted to RSpec and with Trees
      # see https://www.omniref.com/ruby/2.2.0/files/test/test_set.rb
      orig = tree = Sycamore::Tree.new([1, 2, 3])
      expect(tree).not_to be_frozen
      tree << 4
      expect(tree.freeze).to be orig
      expect(tree).to be_frozen
      expect { tree << 5 }.to raise_error RuntimeError
      expect(tree.size).to be 4
    end

  end

end
