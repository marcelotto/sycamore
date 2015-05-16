describe Sycamore::Tree do

  # TODO: Create a custom matcher, which aggregates these to one expectation.
  shared_examples 'added node' do |node|
    it { is_expected.to be_a Sycamore::Tree }
    it { is_expected.to_not be_empty }
    it { is_expected.to include node }
  end

  # TODO: Create a custom matcher, which aggregates these to one expectation.
  shared_examples 'added nodes' do |nodes|
    it { is_expected.to be_a Sycamore::Tree }
    it { is_expected.to_not be_empty }
    it { nodes.each { |node| is_expected.to include(node) } }
  end


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

    context 'when no initial nodes and/or a block given' do
      subject { Sycamore::Tree.new() }
      it { is_expected.to be_a Sycamore::Tree }
      it { is_expected.to be_empty }
    end

    context 'when arguments and/or a block given' do

      # TODO: Remove/Replace these repetitions of #add examples with the inclusion of
      #       a shared example group. But write them a little longer manually, first.

      context 'when a single initial scalar value given' do
        subject { Sycamore::Tree.new 42 }
        include_examples 'added node', 42
      end

      context 'when a single Enumerable given' do
        subject { Sycamore::Tree.new([:foo, :bar, :baz]) }
        include_examples 'added nodes', [:foo, :bar, :baz]
      end

      context 'when multiple scalar values given' do
        subject { Sycamore::Tree.new(:foo, :bar, :baz) }
        # include_examples 'added nodes', [:foo, :bar, :baz]
        pending 'Can/should we support multiple argument initializations?'
      end

      context 'when named argument nodes given?'
      context 'when named argument ... given'

    end

  end


  ################################################################
  # Tree factory function                                        #
  ################################################################

  describe 'Sycamore.Tree()' do

    it 'delegates all calls to .new and #initialize' do
      skip 'Can we somehow execute all the following repetitions of #initialize specs automatically?'
    end

    # TODO: Remove/Replace these repetitions of #initialize examples with the inclusion of
    #       a shared example group. But write them a little longer manually, first.

    context 'when no initial values or named arguments given' do
      subject { Sycamore::Tree() }
      it { is_expected.to be_a Sycamore::Tree }
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

  end



  ################################################################
  # general nodes and children API                               #
  ################################################################

  #####################
  #  query interface  #
  #####################

  describe '#empty?' do
    it 'does behave like a query method' do
      skip 'CQS::Query ExampleGroup'
    end
    it 'does behave like a predicate query method?' do
      skip 'CQS::Predicate ExampleGroup?'
    end

    it 'does return true, when the Tree has no nodes' do
      tree_without_nodes = Sycamore::Tree.new
      expect(tree_without_nodes.empty?).to be_truthy
      expect(tree_without_nodes.empty?).to be true
    end

    it 'does return false, when the Tree has nodes' do
      tree_with_nodes = Sycamore::Tree.new.add_nodes(1)
      expect(tree_with_nodes.empty?).to be_falsey
      expect(tree_with_nodes.empty?).to be false
    end

  end

  describe '#include?' do

    # it 'does behave like a query method' do
    #   skip 'CQS::Query ExampleGroup'
    # end

    # it 'does behave like a predicate query method?' do
    #   skip 'CQS::Predicate ExampleGroup?'
    # end

    context 'when the requested node is in the node set' do
      subject(:tree_with_requested_node) { Tree.new.add_node(:foo) }
      it { is_expected.to include :foo }
    end

    context 'when the requested node is not in the node set' do
      subject(:empty_tree) { Tree.new }
      it { is_expected.to_not include :foo }
    end

  end

  describe '#size' do

    # it 'does behave like a query method' do
    #   skip 'CQS::Query ExampleGroup'
    # end

    # it 'does behave like a predicate query method?' do
    #   skip 'CQS::Predicate ExampleGroup?'
    # end

    context 'when empty' do
      subject { Tree.new.size }
      it { is_expected.to be 0 }
    end

    context 'when having one leaf' do
      subject { Tree.new.add_node(42).size }
      it { is_expected.to be 1 }
    end

    context 'when having more leaves' do
      subject { Tree.new.add_nodes(1, 2, 3).size }
      it { is_expected.to be 3 }
    end

  end


  #####################
  # command interface #
  #####################

  describe '#add' do

    # it 'does behave like a query method' do
    #   skip 'CQS::Query ExampleGroup'
    # end

    context 'when a single initial scalar value argument given' do
      subject { Sycamore::Tree.new.add 42 }
      include_examples 'added node', 42
    end

    context 'when a single Enumerable argument given' do
      subject { Sycamore::Tree.new.add([:foo, :bar, :baz]) }
      include_examples 'added nodes', [:foo, :bar, :baz]
    end

    context 'when multiple scalar value arguments given' do
      subject { Sycamore::Tree.new.add(:foo, :bar, :baz) }
      # include_examples 'added nodes', [:foo, :bar, :baz]
      pending 'Can/should we support multiple argument initializations?'
    end

  end


  describe '#<<' do

    it 'delegates all calls to #add' do
      skip 'Can we somehow execute all the following repetitions of #add specs automatically?'
    end

    # TODO: Remove/Replace these repetitions of #initialize examples with the inclusion of
    #       a shared example group. But write them a little longer manually, first.

    context 'when a single initial scalar value argument given' do
      subject { Sycamore::Tree.new << 42 }
      include_examples 'added node', 42
    end

    context 'when a single Enumerable argument given' do
      subject { Sycamore::Tree.new << [:foo, :bar, :baz] }
      include_examples 'added nodes', [:foo, :bar, :baz]
    end

  end


  describe '#remove' do
    pending
  end


  describe '#>>' do
    it 'delegates all calls to #remove' do
      skip 'Can we somehow execute all the following repetitions of #remove specs automatically?'
    end
  end


  describe '#clear' do

    context 'when not empty' do
      let(:nodes) { [42, :foo] }
      subject { Sycamore::Tree.new(nodes).clear }

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
      it { is_expected.to be_an Array ; skip 'Should we expect nodes to return an Array? Why?' }
    end

    context 'when empty' do
      subject { Sycamore::Tree.new.nodes }
      include_examples 'result invariants'
      it { is_expected.to be_empty }
    end

    context 'when containing a single leaf node' do
      subject { Sycamore::Tree.new.add_node(42).nodes }
      include_examples 'result invariants'
      it { is_expected.to include(42) }
      it { is_expected.to contain_exactly 42 }
    end

    context 'when containing multiple nodes' do

      shared_examples 'node invariants' do
        include_examples 'result invariants'

        it 'does return the nodes unordered' do
          expect(nodes.to_set).to eq leaves
        end

      end

      context 'without children, only leaves' do
        let(:leaves) { Set[:foo, :bar, :baz] }
        subject(:nodes) { Sycamore::Tree.new.add_nodes(*leaves).nodes }

        include_examples 'node invariants'

      end

      context 'with children' do
        pending '#children'
      end

    end

    context 'when another depth than the default 0 given' do
      it 'does merge the nodes of all children down to the given tree depth'
      # TODO: put the specs before in a example group: 'when no depth specified, meaning default depth of 0'
    end

  end


  #####################
  # command interface #
  #####################

  describe '#add_node' do

    # it 'does behave like a query method' do
    #   skip 'CQS::Query ExampleGroup'
    # end

    context 'when a single initial scalar value argument given' do
      subject { Sycamore::Tree.new.add_node 42 }
      include_examples 'added node', 42
    end

    context 'when an Enumerable argument given' do
      # @todo https://www.pivotaltracker.com/story/show/94733228
      #   Do we really need this? If so, document the reasons!
      it 'raises an error' do
        expect { Sycamore::Tree.new.add_node([1, 2]) }. to raise_error(Sycamore::NestedNodeSet)
      end
    end

    end


  describe '#add_nodes' do

    # it 'does behave like a query method' do
    #   skip 'CQS::Query ExampleGroup'
    # end

    context 'when a single scalar value argument given' do
      subject { Sycamore::Tree.new.add_nodes 42 }
      include_examples 'added node', 42
    end

    context 'when multiple scalar value arguments given' do
      subject { Sycamore::Tree.new.add_nodes(:foo, :bar, :baz) }
      include_examples 'added nodes', [:foo, :bar, :baz]
    end

    context 'when multiple value arguments with Enumerables given' do
      # @todo https://www.pivotaltracker.com/story/show/94733228
      #   Do we really need this? If so, document the reasons!
      it 'raises an error' do
        expect { Sycamore::Tree.new.add_nodes([1, [2, 3]]) }. to raise_error(Sycamore::NestedNodeSet)
      end
    end

    context 'when a single Enumerable given' do
      subject { Sycamore::Tree.new.add_nodes [:foo, :bar, :baz] }
      include_examples 'added nodes', [:foo, :bar, :baz]
    end

  end


  describe '#remove_node' do

    context 'when the given node is in this tree' do
      let(:nodes) { [42, :foo] }
      subject(:tree) { Sycamore::Tree.new(nodes).remove_node(42) }

      it { is_expected.not_to include 42 }
      it { is_expected.to include :foo }

      it 'does decrease the size' do
        expect(tree.size).to be nodes.size - 1
      end
    end

    context 'when the given node is not in this tree' do
      let(:nodes) { [:foo] }
      subject(:tree) { Sycamore::Tree.new(nodes).remove_node(42) }

      it { is_expected.not_to include 42 }
      it { is_expected.to include :foo }

      it 'does not decrease the size' do
        expect(tree.size).to be nodes.size
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

  # describe '#child' do
  #
  #   shared_examples 'not found' do
  #     it 'does return an Absence'
  #     it 'does ??? the NothingTree'
  #   end
  #
  #   context 'when given node not found' do
  #     include_examples 'not found'
  #   end
  #
  #   context 'when given node is a leaf, i.e. has no child tree' do
  #     include_examples 'not found'
  #   end
  #
  # end


  #####################
  # command interface #
  #####################



  ################################################################
  # Tree as an Enumerable                                        #
  ################################################################


  ################################################################
  # Various Ruby protocols                                       #
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



  ##########################################
  # equality as recursive node equivalence
  ##########################################


  ##########################################
  # conversion
  ##########################################



end
