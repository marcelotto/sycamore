describe Sycamore::Tree do

  it { is_expected.to be_a Enumerable }

  let(:subclass) { Class.new(Sycamore::Tree) }


  specify { expect { Sycamore::Tree[].data }.to raise_error NoMethodError }

  describe 'CQS reflection class methods' do
    specify 'all Tree methods are separated into command and query methods' do
      # TODO: Should we also separate the inherited methods into commands and queries? At least the command methods are required for proper Absence and Nothing behaviour.
      tree_methods =
        Sycamore::Tree.public_instance_methods(false).to_set.to_a.sort
      command_query_methods =
        (Sycamore::Tree.command_methods + Sycamore::Tree.query_methods).to_set.to_a.sort
      expect( tree_methods ).to eq command_query_methods
    end
  end


  ############################################################################
  # construction
  ############################################################################

  describe '.new' do
    context 'when given no arguments and no block' do
      specify { expect( Sycamore::Tree.new ).to be_a Sycamore::Tree }
      specify { expect( Sycamore::Tree.new ).to be_empty }
    end
  end

  describe '.with' do
    context 'when given no arguments and no block' do
      subject { Sycamore::Tree[] }
      it { is_expected.to be_a Sycamore::Tree }
      it { is_expected.to be_empty }
    end

    context 'when given a single atomic value' do
      it 'does return a new tree' do
        expect( Sycamore::Tree[1] ).to be_a Sycamore::Tree
      end

      it 'does initialize the new tree with the given value' do
        expect( Sycamore::Tree[1] ).to include_node 1
      end
    end

    context 'when given a single array' do
      it 'does initialize the new tree with the elements of the array' do
        expect( Sycamore::Tree[[1, 2]]       ).to include_nodes 1, 2
        expect( Sycamore::Tree[Set[1, 2, 2]] ).to include_nodes 1, 2
        expect( Sycamore::Tree[[1, 2, 2]]    ).to include_nodes 1, 2
        expect( Sycamore::Tree[[1, 2]].size  ).to be 2
        expect( Sycamore::Tree[[1, 2, :foo]] ).to include_nodes 1, 2, :foo
      end
    end

    context 'when given a single hash' do
      it 'does initialize the new tree with the elements of the hash' do
        tree = Sycamore::Tree[a: 1, b: 2]
        expect(tree).to include :a
        expect(tree).to include :b
        expect(tree[:a]).to include 1
        expect(tree[:b]).to include 2
      end
    end

    context 'when given multiple arguments' do
      context 'when all arguments are atomic' do
        it 'does initialize the new tree with the given values' do
          expect( Sycamore::Tree[1, 2]       ).to include_nodes 1, 2
          expect( Sycamore::Tree[1, 2, 2]    ).to include_nodes 1, 2
          expect( Sycamore::Tree[1, 2].size  ).to be 2
          expect( Sycamore::Tree[1, 2, :foo] ).to include_nodes 1, 2, :foo
        end
      end

      context 'when all arguments are atomic or tree-like' do
        it 'does initialize the new tree with the given values' do
          expect( Sycamore::Tree[1, {2 => 3}] ).to include_node 1
          expect( Sycamore::Tree[1, {2 => 3}] ).to include_tree({2 => 3})
        end
      end

      context 'when some arguments are non-tree-like enumerables' do
        it 'does raise an error' do
          expect { Sycamore::Tree[1, [2]] }.to raise_error Sycamore::InvalidNode
          expect { Sycamore::Tree[[1, 2], [3, 4]] }.to raise_error Sycamore::InvalidNode
        end
      end
    end

  end

  describe '#new_child' do
    it 'does create a tree of the same type as the parent' do
      expect( Sycamore::Tree.new.new_child(1) ).to be_instance_of Sycamore::Tree
      expect(       subclass.new.new_child(1) ).to be_instance_of subclass
    end
  end


  ############################################################################
  # Absence and Nothing predicates
  ############################################################################

  describe '#nothing?' do
    specify { expect( Sycamore::Tree.new.nothing? ).to be false }
  end

  describe '#absent?' do
    specify { expect( Sycamore::Tree.new.absent? ).to be false }
  end

  describe '#present?' do
    specify { expect( Sycamore::Tree.new.present?    ).to be false }
    specify { expect( Sycamore::Tree[0 ].present?    ).to be true }
    specify { expect( Sycamore::Tree[''].present?    ).to be true }
    specify { expect( Sycamore::Tree[false].present? ).to be true }
  end


  ############################################################################
  # Various
  ############################################################################

  describe '#empty?' do
    it 'does return true, when the Tree has no nodes' do
      expect( Sycamore::Tree.new.empty?               ).to be true
      expect( Sycamore::Tree[nil              ].empty?).to be true
      expect( Sycamore::Tree[Sycamore::Nothing].empty?).to be true
    end

    it 'does return false, when the Tree has nodes' do
      expect( Sycamore::Tree[42              ].empty? ).to be false
      expect( Sycamore::Tree[[42]            ].empty? ).to be false
      expect( Sycamore::Tree[property: :value].empty? ).to be false
    end
  end

  ############################################################################

  describe '#size' do
    it 'does return 0, when empty' do
      expect( Sycamore::Tree.new.size ).to be 0
      expect( Sycamore::Tree.new.add(:foo).delete(:foo).size ).to be 0
    end

    it 'does return the number of nodes' do
      expect( Sycamore::Tree[1             ].size ).to be 1
      expect( Sycamore::Tree[:foo, 2, 'bar'].size ).to be 3
      expect( Sycamore::Tree[1,2,2,3,3,3   ].size ).to be 3
    end

    it 'does return the number of nodes, not counting the nodes of the children' do
      expect( Sycamore::Tree[a: [1,2,3]  ].size ).to be 1
      expect( Sycamore::Tree[a: 1, b: nil].size ).to be 2
    end
  end

  ############################################################################

  describe '#height' do
    it 'does return 0, when empty' do
      expect( Sycamore::Tree.new.height ).to be 0
      expect( Sycamore::Tree.new.add(:foo).delete(:foo).height ).to be 0
    end

    it 'does return the length of the longest path' do
      expect( Sycamore::Tree[42        ].height ).to be 1
      expect( Sycamore::Tree[1,2,3     ].height ).to be 1
      expect( Sycamore::Tree[a: [1,2,3]].height ).to be 2
      expect( Sycamore::Tree[:a, b: 1  ].height ).to be 2
    end
  end

  ############################################################################

  describe '#leaf?' do
    it 'does return true, when the given node is present and has no child tree' do
      expect( Sycamore::Tree[1                     ].leaf?(1) ).to be true
      expect( Sycamore::Tree[1 => nil              ].leaf?(1) ).to be true
      expect( Sycamore::Tree[1 => Sycamore::Nothing].leaf?(1) ).to be true
      expect( Sycamore::Tree[1 => :foo, 2 => nil   ].leaf?(2) ).to be true
    end

    it 'does return true, when the given node is present and has an empty child tree' do
      tree = Sycamore::Tree[1 => :foo]
      tree[1].clear
      expect(tree.leaf?(1)).to be true
    end

    it 'does return false, when the given node is not present' do
      expect( Sycamore::Tree.new.leaf?(42) ).to be false
      expect( Sycamore::Tree[43].leaf?(42) ).to be false
    end

    it 'does return false, when the given node has a child' do
      expect( Sycamore::Tree[1 => :foo          ].leaf?(1) ).to be false
      expect( Sycamore::Tree[1 => :foo, 2 => nil].leaf?(1) ).to be false
    end

    context 'edge cases' do
      it 'does return false, when given nil' do
        expect( Sycamore::Tree.new.leaf?(nil)  ).to be false
        expect( Sycamore::Tree[nil].leaf?(nil) ).to be false
      end
    end
  end

  ############################################################################

  describe '#strict_leaf?' do
    it 'does return true, when the given node is present and has no child tree' do
      expect( Sycamore::Tree[1                     ].strict_leaf?(1) ).to be true
      expect( Sycamore::Tree[1 => nil              ].strict_leaf?(1) ).to be true
      expect( Sycamore::Tree[1 => Sycamore::Nothing].strict_leaf?(1) ).to be true
      expect( Sycamore::Tree[1 => :foo, 2 => nil   ].strict_leaf?(2) ).to be true
    end

    it 'does return false, when the given node is present and has an empty child tree' do
      tree = Sycamore::Tree[1 => :foo]
      tree[1].clear
      expect(tree.strict_leaf?(1)).to be false
    end

    it 'does return false, when the given node is not present' do
      expect( Sycamore::Tree.new.strict_leaf?(42) ).to be false
      expect( Sycamore::Tree[43].strict_leaf?(42) ).to be false
    end

    it 'does return false, when the given node has a child' do
      expect( Sycamore::Tree[1 => :foo          ].strict_leaf?(1) ).to be false
      expect( Sycamore::Tree[1 => :foo, 2 => nil].strict_leaf?(1) ).to be false
    end

    context 'edge cases' do
      it 'does return false, when given nil' do
        expect( Sycamore::Tree.new.strict_leaf?(nil)  ).to be false
        expect( Sycamore::Tree[nil].strict_leaf?(nil) ).to be false
      end
    end
  end

  ############################################################################

  describe '#strict_leaves?' do
    context 'when given a single atomic value' do
      # see #strict_leaf?
    end

    context 'without arguments' do
      it 'does return true, when none of the nodes has children' do
        expect( Sycamore::Tree[].strict_leaves?                       ).to be true
        expect( Sycamore::Tree[1].strict_leaves?                      ).to be true
        expect( Sycamore::Tree[1 => nil].strict_leaves?               ).to be true
        expect( Sycamore::Tree[1 => Sycamore::Nothing].strict_leaves? ).to be true
        expect( Sycamore::Tree[1, 2, 3].strict_leaves?                ).to be true
      end

      it 'does return false, when some of the nodes have children' do
        expect( Sycamore::Tree[1 => 2                         ].strict_leaves? ).to be false
        expect( Sycamore::Tree[1 => :a, 2 => nil, 3 => nil    ].strict_leaves? ).to be false
        expect( Sycamore::Tree[1 => :a, 2 => Sycamore::Nothing].strict_leaves? ).to be false
      end

      it 'does return false, when some of the nodes have an empty child tree' do
        expect( Sycamore::Tree[1 => []                        ].strict_leaves? ).to be false
        expect( Sycamore::Tree[1 => [], 2 => nil, 3 => nil    ].strict_leaves? ).to be false
        expect( Sycamore::Tree[1 => [], 2 => Sycamore::Nothing].strict_leaves? ).to be false
      end
    end

    context 'when given arguments' do
      it 'does return true, if all given nodes are present and have no child tree' do
        expect( Sycamore::Tree[1, 2, 3           ].strict_leaves?(1,2,3)   ).to be true
        expect( Sycamore::Tree[1 => nil, 2 => nil].strict_leaves?(1,2)     ).to be true
      end

      it 'does return false, if some of the given nodes are not present' do
        expect( Sycamore::Tree[1,2].strict_leaves?(1,2,3) ).to be false
        expect( Sycamore::Tree[].strict_leaves?(1,2,3)    ).to be false
      end

      it 'does return false, if some of the given nodes have a child' do
        expect( Sycamore::Tree[1 => :a, 2 => nil].strict_leaves?(1,2) ).to be false
      end

      it 'does return false, if some of the given nodes have an empty child tree' do
        expect( Sycamore::Tree[1 => [], 2 => nil].strict_leaves?(1,2) ).to be false
      end
    end

    context 'edge cases' do
      it 'does return false, when given nil' do
        expect( Sycamore::Tree[   ].strict_leaves?(nil) ).to be false
        expect( Sycamore::Tree[nil].strict_leaves?(nil) ).to be false
      end
    end
  end

  ############################################################################

  describe '#external?' do
    context 'when given a single atomic value' do
      # see #leaf?
    end

    context 'without arguments' do
      it 'does return true, when none of the nodes has children' do
        expect( Sycamore::Tree[].external?                       ).to be true
        expect( Sycamore::Tree[1].external?                      ).to be true
        expect( Sycamore::Tree[1 => nil].external?               ).to be true
        expect( Sycamore::Tree[1 => Sycamore::Nothing].external? ).to be true
        expect( Sycamore::Tree[1, 2, 3].external?                ).to be true
      end

      it 'does return false, when some of the nodes have children' do
        expect( Sycamore::Tree[1 => 2                         ].external? ).to be false
        expect( Sycamore::Tree[1 => :a, 2 => nil, 3 => nil    ].external? ).to be false
        expect( Sycamore::Tree[1 => :a, 2 => Sycamore::Nothing].external? ).to be false
      end

      it 'does return false, when some of the nodes have an empty child tree' do
        expect( Sycamore::Tree[1 => []                        ].external? ).to be true
        expect( Sycamore::Tree[1 => [], 2 => nil, 3 => nil    ].external? ).to be true
        expect( Sycamore::Tree[1 => [], 2 => Sycamore::Nothing].external? ).to be true
      end
    end

    context 'when given arguments' do
      it 'does return true, if all given nodes are present and have no children' do
        expect( Sycamore::Tree[1, 2, 3           ].external?(1,2,3)   ).to be true
        expect( Sycamore::Tree[1 => nil, 2 => nil].external?(1,2)     ).to be true
      end

      it 'does return true, if some of the given nodes have an empty child tree' do
        expect( Sycamore::Tree[1 => [], 2 => nil].external?(1,2) ).to be true
      end

      it 'does return false, if some of the given nodes are not present' do
        expect( Sycamore::Tree[1,2].external?(1,2,3) ).to be false
        expect( Sycamore::Tree[].external?(1,2,3)    ).to be false
      end

      it 'does return false, if some of the given nodes have a child' do
        expect( Sycamore::Tree[1 => :a, 2 => nil].external?(1,2) ).to be false
      end
    end

    context 'edge cases' do
      it 'does return false, when given nil' do
        expect( Sycamore::Tree[   ].external?(nil) ).to be false
        expect( Sycamore::Tree[nil].external?(nil) ).to be false
      end
    end
  end

  ############################################################################

  describe '#internal?' do
    context 'when given no arguments' do
      it 'does return true, when all nodes have children' do
        expect( Sycamore::Tree[1 => 2].internal? ).to be true
      end

      it 'does return false, when some of the nodes are leaves' do
        expect( Sycamore::Tree[].internal?                       ).to be false
        expect( Sycamore::Tree[1].internal?                      ).to be false
        expect( Sycamore::Tree[1 => nil].internal?               ).to be false
        expect( Sycamore::Tree[1 => Sycamore::Nothing].internal? ).to be false
        expect( Sycamore::Tree[1, 2, 3].internal?                ).to be false
        expect( Sycamore::Tree[1 => :a, 2 => nil].internal?      ).to be false
      end
    end

    context 'when given arguments' do
      it 'does return true, when all of the given nodes are present and have children' do
        expect( Sycamore::Tree[1 => 2           ].internal?(1) ).to be true
        expect( Sycamore::Tree[1 => :a, 2 => nil].internal?(1) ).to be true
      end

      it 'does return false, if some of the given nodes are present, but have no children' do
        expect( Sycamore::Tree[1, 2, 3           ].internal?(1,2,3)   ).to be false
        expect( Sycamore::Tree[1 => nil, 2 => nil].internal?(1,2)     ).to be false
        expect( Sycamore::Tree[1 => :a, 2 => nil ].internal?(1,2)     ).to be false
      end

      it 'does return false, if some of the given nodes are not present' do
        expect( Sycamore::Tree.new.internal?(42)        ).to be false
        expect( Sycamore::Tree[1, 2  ].internal?(1,2,3) ).to be false
        expect( Sycamore::Tree[1 => 2].internal?(2)     ).to be false
      end
    end

    context 'edge cases' do
      context 'when given nil' do
        specify { expect( Sycamore::Tree[   ].internal?(nil) ).to be false }
        specify { expect( Sycamore::Tree[nil].internal?(nil) ).to be false }
      end
    end
  end

  ############################################################################

  describe '#dup' do
    it 'does returns a different but equal Tree' do
      tree = Sycamore::Tree[foo: :bar]
      duplicate = tree.dup

      expect( duplicate ).not_to be tree
      expect( duplicate ).to eql tree
      expect( tree[:foo] ).not_to be duplicate[:foo]
    end

    it 'does return an independent Tree' do
      tree = Sycamore::Tree[foo: {bar: :baz}]
      duplicate = tree.dup
      tree.add :more

      expect( duplicate ).not_to eql tree

      duplicate = tree.dup
      tree[:foo] << :more

      expect( duplicate ).not_to eql tree
    end

    it 'returns an unfrozen tree, even if the original was frozen' do
      tree = Sycamore::Tree.new
      tree.freeze
      duplicate = tree.dup

      expect( duplicate ).not_to be_frozen
    end

    it 'returns a tainted tree, if the original was tainted' do
      tree = Sycamore::Tree.new
      tree.taint
      duplicate = tree.dup

      expect( duplicate ).to be_tainted
    end
  end

  ############################################################################

  describe '#clone' do
    it 'does returns a different but equal Tree' do
      tree = Sycamore::Tree[foo: :bar]
      klone = tree.clone

      expect( klone ).not_to be tree
      expect( klone ).to eql tree
      expect( klone[:foo] ).not_to be tree[:foo]
    end

    it 'does return an independent Tree' do
      tree = Sycamore::Tree[foo: {bar: :baz}]
      klone = tree.clone
      tree.add :more

      expect( klone ).not_to eql tree

      klone = tree.clone
      tree[:foo] << :more

      expect( klone ).not_to eql tree
    end

    it 'returns a frozen tree, if the original was frozen' do
      tree = Sycamore::Tree.new
      tree.freeze
      klone = tree.clone

      expect( klone ).to be_frozen
    end

    it 'returns a tainted tree, if the original was tainted' do
      tree = Sycamore::Tree.new
      tree.taint
      klone = tree.clone

      expect( klone ).to be_tainted
    end

    it 'does copy singleton methods' do
      tree = Sycamore::Tree.new
      def tree.some_method ; end

      klone = tree.clone
      expect(klone).to respond_to :some_method
    end

  end

  ############################################################################

  describe '#freeze' do
    it 'behaves Object#freeze conform' do
      # stolen from Ruby's tests of set.rb (test_freeze) adapted to RSpec and with Trees
      # see https://www.omniref.com/ruby/2.2.0/files/test/test_set.rb
      orig = tree = Sycamore::Tree[1, 2, 3]
      expect(tree).not_to be_frozen
      tree << 4
      expect(tree.freeze).to be orig
      expect(tree).to be_frozen
      expect { tree << 5 }.to raise_error RuntimeError
      expect(tree.size).to be 4
    end

    it 'does freeze all children' do
      frozen_tree = Sycamore::Tree[foo: :bar].freeze
      expect( frozen_tree[:foo] ).to be_frozen
    end

    it 'does freeze all children recursively' do
      frozen_tree = Sycamore::Tree[foo: {bar: :baz}].freeze
      expect( frozen_tree[:foo, :bar] ).to be_frozen
    end
  end

end
