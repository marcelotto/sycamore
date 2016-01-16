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
  # general nodes and children access
  ############################################################################

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
      context 'when no reduce function specified' do
        it 'does raise a TypeError' do
          expect { Sycamore::Tree[:foo, :bar].node }.to raise_error TypeError
          expect { Sycamore::Tree[foo: 1, bar: 2, baz: nil].node }.to raise_error TypeError
        end
      end

      context 'when a reducer or selector function specified' do
        it 'does return the application of reduce function on the node set' do
          pending
          expect( Sycamore::Tree[1,2,3].node(&:max) ).to eq 3
          expect( Sycamore::Tree[1,2,3]
                    .node { |nodes| nodes.reduce { |value, sum| sum += value } }
          ).to eq 6
        end
      end
    end
  end

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

  describe '#include?' do
    context 'when given a single atomic value' do
      it 'does return true, when the value is in the set of nodes' do
        expect( Sycamore::Tree[1         ].include? 1    ).to be true
        expect( Sycamore::Tree[1, 2      ].include? 1    ).to be true
        expect( Sycamore::Tree[1, 2      ].include? 2    ).to be true
        expect( Sycamore::Tree[42, 'text'].include? 42   ).to be true
        expect( Sycamore::Tree[foo: :bar ].include? :foo ).to be true
      end

      it 'does return false, when the value is not in the set of nodes' do
        expect( Sycamore::Tree[         ].include?(number) ).to be false
        expect( Sycamore::Tree[1        ].include? 2       ).to be false
        expect( Sycamore::Tree[1, 2     ].include? [1, 3]  ).to be false
        expect( Sycamore::Tree[foo: :bar].include? :bar    ).to be false
      end
    end

    context 'when given a single array' do
      it 'does return true, when all elements are in the set of nodes' do
        expect( Sycamore::Tree[1, 2      ].include? [1     ] ).to be true
        expect( Sycamore::Tree[1, 2      ].include? [1, 2  ] ).to be true
        expect( Sycamore::Tree[1, 2      ].include? [2, 1  ] ).to be true
        expect( Sycamore::Tree[1, 2, 3   ].include? [1, 2  ] ).to be true
        expect( Sycamore::Tree[:a, :b, :c].include? [:c, :a] ).to be true
      end

      it 'does return false, when some elements are not in the set of nodes' do
        expect( Sycamore::Tree[            ].include? [1        ] ).to be false
        expect( Sycamore::Tree[1, 2        ].include? [3        ] ).to be false
        expect( Sycamore::Tree[1, 2        ].include? [1, 3     ] ).to be false
        expect( Sycamore::Tree[:a, :b, :c  ].include? [:a, :b, 1] ).to be false
        expect( Sycamore::Tree[a: :b, c: :d].include? [:a, :d   ] ).to be false
      end
    end

    context 'when given a single hash' do
      it 'does return true, when all of its elements are part of the tree and nested equally' do
        expect( Sycamore::Tree[1 => 2].include?(1 => 2) ).to be true
        expect( Sycamore::Tree[1 => 2].include?(1 => nil) ).to be true
        expect( Sycamore::Tree[1 => 2].include?(1 => Sycamore::Nothing) ).to be true
        expect( Sycamore::Tree[1 => 2].include?(1 => { 2 => nil }) ).to be true
        expect( Sycamore::Tree[1 => 2].include?(1 => { 2 => Sycamore::Nothing }) ).to be true
        expect( Sycamore::Tree[1 => [2, 3]].include?(1 => 2) ).to be true
        expect( Sycamore::Tree[1 => 2, 3 => 1].include?(1 => 2) ).to be true
        expect( Sycamore::Tree[1 => 2, 3 => 1].include?(1 => 2, 3 => 1) ).to be true
        expect( Sycamore::Tree[1 => [2, 3], 3 => 1].include?(1 => 2, 3 => 1) ).to be true
        expect( Sycamore::Tree[1 => [2, 3], 3 => 1].include?(1 => 2, 3 => nil) ).to be true
        expect( Sycamore::Tree[1 => [2, 3], 3 => 1].include?(1 => 2, 3 => Sycamore::Nothing) ).to be true
      end

      it 'does return false, when some of its elements are not part of the tree' do
        expect( Sycamore::Tree[       ].include?(1 => 2)         ).to be false
        expect( Sycamore::Tree[1      ].include?(1 => 2)         ).to be false
        expect( Sycamore::Tree[42 => 2].include?(1 => 2)         ).to be false
        expect( Sycamore::Tree[1 => 2 ].include?(1 => [2, 3])    ).to be false
        expect( Sycamore::Tree[1 => 2 ].include?(1 => 2, 3 => 1) ).to be false
      end

      it 'does return false, when the elements do not match the tree structure' do
        expect( Sycamore::Tree[2 => 1].include?(1 => 2) ).to be false
      end
    end

    context 'when given another Tree' do
      pending '#include? with another Tree' # TODO: Should we duplicate all of above specs (for atom, array, hash) with the args converted to a Tree?
      # specify { expect( Sycamore::Tree[1,2].include? Sycamore::Tree[1] ).to be true }
      # specify { expect( Sycamore::Tree[1,2].include? Sycamore::Tree[2] ).to be true }
      # specify { expect( Sycamore::Tree[1,2].include? Sycamore::Tree[1] ).to be true }
      # specify { expect( Sycamore::Tree[1,2].include? Sycamore::Tree[1, 2] ).to be true }
      # specify { expect( Sycamore::Tree[1,2].include? Sycamore::Tree[1, 3] ).to be false }
    end

    context 'edge cases' do
      context 'when given a single value' do
        specify { expect( Sycamore::Tree[false].include? false).to be true }
        specify { expect( Sycamore::Tree[0    ].include? 0    ).to be true }
        specify { expect( Sycamore::Tree[''   ].include? ''   ).to be true }
      end
    end
  end

  ############################################################################

  # TODO: Replace RSpec yield matchers! All?

  describe '#each' do

    context 'when a block given' do
      context 'when empty' do
        specify { expect { |b| Sycamore::Tree[].each(&b) }.not_to yield_control }
      end

      context 'when the block has arity 2' do

        context 'when having one leaf' do
          specify { expect { |b| Sycamore::Tree[1].each(&b) }.to yield_with_args([1, nil]) } #
          specify { pending ; expect { |b| Sycamore::Tree[1].each(&b) }.to yield_with_args(1, nil) }
          specify { pending '???' ; expect { |b| Sycamore::Tree[1 => 2].each(&b) }.to yield_with_args(1, Sycamore::Tree[2]) }
          # specify { pending 'this calls implicitely to_a' ; expect { |b| Sycamore::Tree[1 => 2].each(&b) }.to yield_with_args([1, Tree[2]]) }
          # specify { expect { |b| Sycamore::Tree[1 => 2].each(&b) }.to yield_with_args(1, Sycamore::Tree[2]) }
          specify { expect { |b| Sycamore::Tree[1 => 2].each(&b) }.to yield_with_args([1, Sycamore::Tree[2]]) }
          specify { expect { |b| Sycamore::Tree[1].each(&b) }.to yield_control.exactly(1).times }
          specify { expect { |b| Sycamore::Tree[1].each(&b) }.to yield_successive_args([1, nil]) }
        end

        context 'when having more leaves' do
          specify { expect { |b| Sycamore::Tree[1,2,3].each(&b) }.to yield_control.exactly(3).times }
          specify { expect { |b| Sycamore::Tree[1,2,3].each(&b) }.to yield_successive_args([1, nil], [2, nil], [3, nil]) }
        end

        context 'when having nodes with children' do
          # specify { expect( Sycamore::Tree[a: 1, b: nil].size ).to be 2 }
        end

      end

      context 'when the block has arity <=1' do

        context 'when having one leaf' do
          specify { pending 'replace RSpec yield matchers' ; expect { |b| Sycamore::Tree[1].each(&b) }.to yield_with_args(1) } #
          specify { pending 'replace RSpec yield matchers' ; expect { |b| Sycamore::Tree[1 => 2].each(&b) }.to yield_with_args(1) }
          # specify { pending 'this calls implicitely to_a' ; expect { |b| Sycamore::Tree[1 => 2].each(&b) }.to yield_with_args([1, Sycamore::Tree[2]]) }
          # specify { expect { |b| Sycamore::Tree[1 => 2].each(&b) }.to yield_with_args(1, Sycamore::Tree[2]) }
          specify { expect { |b| Sycamore::Tree[1 => 2].each(&b) }.to yield_with_args([1, Sycamore::Tree[2]]) }
        end

        context 'when having more leaves' do
        end

        context 'when having nodes with children' do
          # specify { expect( Sycamore::Tree[a: 1, b: nil].size ).to be 2 }
        end

      end


    end

    context 'when no block given' do
      pending
    end

  end

  ############################################################################

  describe '#each_path' do
    specify { expect(Sycamore::Tree[1     ].paths.to_a ).to eq [Sycamore::Path[1]] }
    specify { expect(Sycamore::Tree[1,2   ].paths.to_a ).to eq [Sycamore::Path[1], Sycamore::Path[2]] }
    specify { expect(Sycamore::Tree[1 => 2].paths.to_a ).to eq [Sycamore::Path[1, 2]] }
    specify { expect(Sycamore::Tree[1 => { 2 => [3, 4] }].paths.to_a )
             .to eq [Sycamore::Path[1, 2, 3], Sycamore::Path[1, 2, 4]] }
  end

  ############################################################################

  describe '#path?' do

    context 'when given a Path' do
      specify { expect( Sycamore::Tree[].path? Path[] ).to be true }
      specify { expect( Sycamore::Tree[].path? Path[42] ).to be false }
      specify { expect( Sycamore::Tree[].path? Path[1,2,3] ).to be false }

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


  ##########################################
  # conversion
  ##########################################

  # TODO: shared example or matcher for ...
  describe '#to_???' do
    specify { expect( Sycamore::Tree[         ].to_h ).to eq( {} ) }
    specify { expect( Sycamore::Tree[ 1       ].to_h ).to eq( 1 ) }
    specify { expect( Sycamore::Tree[ 1, 2, 3 ].to_h ).to eq( [1, 2, 3] ) }
    specify { expect( Sycamore::Tree[ :a => 1 ].to_h ).to eq( { :a => 1 } ) }
    specify { expect( Sycamore::Tree[ :a => 1, :b => [2, 3] ].to_h ).to eq(
                                    { :a => 1, :b => [2, 3] } ) }
  end

  # describe '#to_a' do
  #   specify { expect( Sycamore::Tree[         ].to_a ).to eq( [] ) }
  #   specify { expect( Sycamore::Tree[ 1       ].to_a ).to eq( [1] ) }
  #   specify { expect( Sycamore::Tree[ 1, 2, 3 ].to_a ).to eq( [1, 2, 3] ) }
  #   specify { expect( Sycamore::Tree[ :a => 1 ].to_a ).to eq( [ :a => [1] ] ) }
  #   specify { expect( Sycamore::Tree[ :a => 1, :b => [2, 3] ].to_a ).to eq(
  #                                   [ :a => [1], :b => [2, 3] ] ) }
  # end

  describe '#to_h' do
    pending
  end

  describe '#to_s' do
    it 'delegates to the hash representation of #to_h'
    # TODO: shared example or matcher for ...

    specify { expect( Sycamore::Tree[         ].to_s ).to eq( '{}' ) }
    specify { expect( Sycamore::Tree[ 1       ].to_s ).to eq( '1' ) }
    specify { expect( Sycamore::Tree[ 1, 2, 3 ].to_s ).to eq( '[1, 2, 3]' ) }
    specify { expect( Sycamore::Tree[ :a => 1 ].to_s ).to eq( '{:a=>1}' ) }
    specify { expect( Sycamore::Tree[ :a => 1, :b => [2, 3] ].to_s ).to eq(
                          '{:a=>1, :b=>[2, 3]}' ) }

  end

  describe '#inspect' do

    shared_examples_for 'every inspect string' do |tree|
      it 'is in the usual Ruby inspect style' do
        expect( tree.inspect ).to match /^#<Sycamore::Tree:0x/
      end
      it 'contains the object identity' do
        expect( tree.inspect ).to include tree.object_id.to_s(16)
      end
      it 'contains the hash representation' do
        expect( tree.inspect ).to include tree.to_h.inspect
      end
    end

    include_examples 'every inspect string', Sycamore::Tree.new
    include_examples 'every inspect string', Sycamore::Tree[1,2,3]
    include_examples 'every inspect string', Sycamore::Tree[foo: 1, bar: [2,3]]

  end



  ################################################################
  # Various other Ruby protocols                                 #
  ################################################################

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
