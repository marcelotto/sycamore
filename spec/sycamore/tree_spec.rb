describe Sycamore::Tree do

  ############################################################################
  # creation

  describe '#initialize' do

    context 'when no initial values or named arguments given' do
      subject { Sycamore::Tree.new() }
      it { is_expected.to be_a Sycamore::Tree }
      it { is_expected.to be_empty }
    end

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

  end

  ########################################################################
  # Tree factory function

  describe 'Sycamore.Tree()' do

    it 'delegates all calls to .new and #initialize' do
      skip 'Can we somehow execute all the following repetitions of #initialize specs automatically?'
    end

    # TODO: Replace these repetitions of #initialize examples with the inclusion of
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
        before { require 'sycamore/extension' }
        it 'creates a Tree' do
          expect( Tree() ).to be_a Sycamore::Tree
        end
      end

    end

  end

  ########################################################################
  # nodes and children                                                   #
  ########################################################################

  #####################
  #  query interface  #
  #####################

  describe '#empty?' do
    it 'does behave like a query method' do
      skip 'CQS::Query::Example::Group'
    end
    it 'does behave like a predicate query method?' do
      skip 'CQS::Predicate::Example::Group?'
    end

    it 'does return true, when the Tree has no nodes' do
      tree_without_nodes = Sycamore::Tree.new
      expect(tree_without_nodes.empty?).to be_truthy
      expect(tree_without_nodes.empty?).to be true
    end

    it 'does return false, when the Tree has nodes' do
      pending '#add_nodes'
      tree_with_nodes = Sycamore::Tree.new.add_nodes(1)
      expect(tree_with_nodes.empty?).to be_falsey
      expect(tree_with_nodes.empty?).to be false
    end

  end

  #####################
  # command interface #
  #####################


  ########################################
  # Nodes
  ########################################

  #####################
  #  query interface  #
  #####################

  #####################
  # command interface #
  #####################


  ########################################
  # Children
  ########################################

  #####################
  #  query interface  #
  #####################

  #####################
  # command interface #
  #####################



  ############################################################################
  # equality as recursive node equivalence
  ############################################################################


end
