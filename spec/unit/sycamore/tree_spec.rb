describe Sycamore::Tree do

  it { is_expected.to be_a Enumerable }

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

  describe '#initialize' do
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
        it 'does raise an NestedNodeSet exception' do
          expect { Sycamore::Tree[1, [2]] }.to raise_error Sycamore::NestedNodeSet
          expect { Sycamore::Tree[[1, 2], [3, 4]] }.to raise_error Sycamore::NestedNodeSet
        end
      end
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

      tree = Sycamore::Tree[1 => :foo, 2 => nil]
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

    context 'when given a hash' do
      it 'raises a TypeError' do
        expect { Sycamore::Tree.new.leaf?(a: 1) }.to raise_error TypeError
      end
    end

    context 'when given a nested array' do
      it 'raises a TypeError' do
        expect { Sycamore::Tree.new.leaf?([:foo, 1]) }.to raise_error TypeError
      end
    end

    context 'edge cases' do
      context 'when given nil' do
        pending 'This should not be an edge case.'
        specify { expect( Sycamore::Tree.new.leaf?(nil)  ).to be false }
        specify { expect( Sycamore::Tree[nil].leaf?(nil) ).to be false }
      end

      # context 'when given Nothing' do
      #   specify { expect(Tree[].leaf?(Sycamore::Nothing)).to be false }
      #   specify { expect(Tree[Sycamore::Nothing].leaf?(Sycamore::Nothing)).to be false }
      # end
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
    end

    context 'when given arguments' do
      it 'does return true, if all given nodes are present and have no children' do
        expect( Sycamore::Tree[1, 2, 3           ].external?(1,2,3)   ).to be true
        expect( Sycamore::Tree[1 => nil, 2 => nil].external?(1,2)     ).to be true
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
      context 'when given nil' do
        specify { expect( Sycamore::Tree[   ].external?(nil) ).to be false }
        specify { expect( Sycamore::Tree[nil].external?(nil) ).to be false }
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

  end

end
