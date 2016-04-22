describe Sycamore::Tree do

  subject(:tree) { Sycamore::Tree.new }

  ############################################################################

  describe '#add_node_with_empty_child' do
    it 'does add the given node' do
      expect( tree.add_node_with_empty_child(:foo) ).to include_node :foo
    end

    it 'does create the new child with #new_child' do
      expect( tree ).to receive(:new_child)
      tree.add_node_with_empty_child(:foo)
    end

    it 'does add an empty tree as a child of the given node' do
      expect( tree.add_node_with_empty_child(:foo).child_of(:foo) ).to be_a Sycamore::Tree
      expect( tree.add_node_with_empty_child(:foo).child_of(:foo) ).not_to be Sycamore::Nothing
      expect( tree.add_node_with_empty_child(:foo).child_of(:foo) ).not_to be_absent
      expect( tree.add_node_with_empty_child(:foo).child_of(:foo) ).to be_empty

      expect( Sycamore::Tree[:foo].add_node_with_empty_child(:foo).child_of(:foo) ).to be_a Sycamore::Tree
      expect( Sycamore::Tree[:foo].add_node_with_empty_child(:foo).child_of(:foo) ).not_to be Sycamore::Nothing
      expect( Sycamore::Tree[:foo].add_node_with_empty_child(:foo).child_of(:foo) ).not_to be_absent
      expect( Sycamore::Tree[:foo].add_node_with_empty_child(:foo).child_of(:foo) ).to be_empty
    end

    it 'does nothing, when the given node is already present' do
      tree = Sycamore::Tree[foo: :bar]
      expect { tree.add_node_with_empty_child(:foo) }.not_to change { tree.child_of(:foo) }
    end

    context 'edge cases' do
      it 'does treat nil like any other value' do
        expect( tree.add_node_with_empty_child(nil) ).to include_node nil
      end
    end
  end

  ############################################################################

  describe '#add' do
    context 'when given a single node' do
      it 'does add the value to the set of nodes' do
        expect( Sycamore::Tree.new.add 1 ).to include_node 1
      end

      context 'when the given value is already present' do
        it 'does nothing' do
          expect( Sycamore::Tree[1].add(1).size ).to be 1
        end

        it 'does not overwrite the existing children' do
          expect( Sycamore::Tree[a: 1].add(:a) ).to include_tree(a: 1)
        end
      end

      context 'edge cases' do
        it 'does nothing, when given the Nothing tree' do
          expect( Sycamore::Tree.new.add Sycamore::Nothing ).to be_empty
        end

        it 'does treat nil like any other value' do
          expect( Sycamore::Tree.new.add nil).to include_node nil
        end

        it 'does treat false like any other value' do
          expect( Sycamore::Tree.new.add false).to include_node false
        end
      end
    end

    context 'when given an array' do
      it 'does add all values to the set of nodes' do
        expect( Sycamore::Tree.new.add [1,2] ).to include_nodes 1, 2
      end

      it 'does merge the values with the existing nodes' do
        expect( Sycamore::Tree[1,2].add([2,3]).nodes.to_set ).to eql Set[1,2,3]
      end

      it 'does ignore duplicates' do
        expect( Sycamore::Tree.new.add [1,2,2,3,3,3] ).to include_nodes 1, 2, 3
        expect( Sycamore::Tree.new.add(['foo', 'bar', 'baz', 'foo', 'bar']).nodes.to_set).to eql %w[baz foo bar].to_set
      end

      context 'when the array is nested' do
        it 'does treat hashes as trees' do
          expect( Sycamore::Tree.new.add [:a, b: 1]         ).to include_tree({a: nil, b: 1})
          expect( Sycamore::Tree.new.add [:b,  a: 1, c: 2 ] ).to include_tree({a: 1, b: nil, c: 2})
          expect( Sycamore::Tree.new.add [:b, {a: 1, c: 2}] ).to include_tree({a: 1, b: nil, c: 2})
          expect( Sycamore::Tree.new.add [:a, b: {c: 2}   ] ).to include_tree({a: nil, b: {c: 2}})
        end

        it 'does merge the children of duplicate nodes' do
          expect( Sycamore::Tree.new.add [1,{1=>2}] ).to include_tree({1=>2})
          expect( Sycamore::Tree.new.add [1,{1=>2}, {1=>3}] ).to include_tree({1=>[2,3]})
          expect( Sycamore::Tree.new.add [1,{1=>{2=>3}}, {1=>{2=>4}}] ).to include_tree({1=>{2=>[3,4]}})
        end
      end

      context 'when the array contains a nested enumerable that is not Tree-like' do
        it 'raises an error' do
          expect { Sycamore::Tree.new.add([1, [2, 3]]) }.to raise_error Sycamore::InvalidNode
        end

        it 'does not change the tree' do
          expect { tree.add([1, [2, 3]]) }.to raise_error Sycamore::InvalidNode
          expect( tree ).to be_empty
        end
      end

      context 'edge cases' do
        it 'does treat nil like any other value' do
          expect( Sycamore::Tree.new.add([1, nil]).nodes.to_set ).to eq [1, nil].to_set
          expect( Sycamore::Tree.new.add([nil, :foo, nil, :bar]).nodes.to_set).to eql [:foo, :bar, nil].to_set
        end

        it 'does nothing, when given an empty array' do
          expect( Sycamore::Tree.new.add [] ).to be_empty
        end
      end
    end

    ADD_TREE_EXAMPLES = [
      { foo: :bar },
      { foo: [:bar, :baz] },
      { a: 1, b: 2 },
      { a: 1, b: [2,3] },
      { a: [1, 'foo'], b: {2 => 3} },
      { foo: {bar: :baz} },
    ]

    MERGE_TREE_EXAMPLES = [
      { before: {foo: [1, 2]}, add: {foo: [2, 3]}, after: {foo: [1, 2, 3]} },
      { before: {foo: {1=>2}}, add: {foo: {1=>3}}, after: {foo: {1=>[2, 3]}} },
      { before: {noah: { shem: :elam }},
        add:    {noah: { shem: :asshur, japeth: :gomer}},
        after:  {noah: { shem: [:elam, :asshur], japeth: :gomer}} },
    ]

    context 'when given a hash' do
      it 'does add the given tree structure' do
        ADD_TREE_EXAMPLES.each do |example|
          expect( Sycamore::Tree.new.add(example) ).to include_tree example
        end
      end

      it 'does merge the given hash with the existing tree structure' do
        MERGE_TREE_EXAMPLES.each do |example|
          expect( Sycamore::Tree[example[:before]].add(example[:add]) )
            .to eql Sycamore::Tree[example[:after]]
        end
      end

      context 'when given a tree with an enumerable key' do
        it 'raises an error' do
          expect { Sycamore::Tree.new.add([1,2] => 3) }.to raise_error Sycamore::InvalidNode
          expect { Sycamore::Tree.new.add({1 => 2} => 3) }.to raise_error Sycamore::InvalidNode
          expect { Sycamore::Tree.new.add(Sycamore::Tree[1] => 42) }.to raise_error Sycamore::InvalidNode
          expect { Sycamore::Tree.new.add(Sycamore::Nothing => 42) }.to raise_error Sycamore::InvalidNode
        end

        it 'does not change the tree' do
          expect { tree.add([foo: :bar, [1,2] => 3]) }.to raise_error Sycamore::InvalidNode
          expect( tree ).to be_empty
        end
      end

      context 'edge cases' do
        it 'does nothing, when given an empty hash' do
          expect( Sycamore::Tree.new << {} ).to be_empty
        end

        it 'does treat false as a key like any other value' do
          expect( Sycamore::Tree.new.add(false => 1) ).to include_tree({false => 1})
        end

        it 'does treat nil as a key like any other value' do
          expect( Sycamore::Tree.new.add(nil => 1) ).to include_tree({nil => 1})
        end

        it 'does ignore Nothing-like values as children' do
          expect(Sycamore::Tree.new.add({1 => Sycamore::Nothing}).child_of(1)).to be_absent
          expect(Sycamore::Tree.new.add({1 => nil, 2 => nil}).child_of(1)).to be_absent
        end

        it 'does add empty child enumerables as empty trees' do
          expect(Sycamore::Tree.new.add(1 => []).child_of(1)).not_to be_absent
          expect(Sycamore::Tree.new.add({1 => {}, 2 => {}}).child_of(1)).not_to be_absent
        end

        it 'does add a child with a nil node, when given an Array with nil as a child' do
          expect(Sycamore::Tree.new.add({1 => [nil]}).child_of(1)).not_to be_absent
          expect(Sycamore::Tree.new.add({1 => [nil], 2 => [nil]}).child_of(1)).to include_node nil
        end
      end
    end

    context 'when given a tree' do
      it 'does add the tree structure' do
        ADD_TREE_EXAMPLES.each do |example|
          expect( Sycamore::Tree.new.add(example) ).to include_tree example
        end
      end

      it 'does merge the tree with the existing tree structure' do
        MERGE_TREE_EXAMPLES.each do |example|
          expect( Sycamore::Tree[example[:before]] .add(Sycamore::Tree[example[:add]]) )
            .to eql Sycamore::Tree[example[:after]]
        end
      end

      context 'edge cases' do
        it 'does nothing, when given an empty tree' do
          expect( Sycamore::Tree.new << Sycamore::Tree.new ).to be_empty
        end

        it 'does nothing, when given the Nothing tree' do
          expect( Sycamore::Tree.new << Sycamore::Nothing ).to be_empty
        end

        context 'when given an Absence' do
          let(:absent_tree) { Sycamore::Tree.new.child_of(:missing) }

          it 'does ignore it, when it is absent' do
            expect( Sycamore::Tree.new.add absent_tree ).to be_empty
            expect( Sycamore::Tree.new.add(1 => absent_tree).leaf?(1) ).to be true
          end

          it 'does treat it like a normal tree, when it was created' do
            absent_tree << 42

            expect( Sycamore::Tree.new.add absent_tree ).to eql Sycamore::Tree[42]
            expect( Sycamore::Tree.new.add 1 => absent_tree ).to eql Sycamore::Tree[1 => 42]
          end
        end
      end
    end

    context 'when given a single Path object' do
      let(:path) { Sycamore::Path[:foo, :bar, :baz] }

      it 'does add all nodes, when the path does not exist' do
        expect( Sycamore::Tree.new.add(path) ).to include_path(path)
      end

      it 'does add the missing nodes, when the path exists partially' do
        expect( Sycamore::Tree[foo: :bar].add(path) )
          .to eql Sycamore::Tree[foo: {bar: :baz}]
        expect( Sycamore::Tree[foo: :other].add(path) )
          .to eql Sycamore::Tree[foo: {bar: :baz, other: nil}]
      end

      it 'does nothing, when the path already exists' do
        expect( Sycamore::Tree[foo: {bar: :baz}].add(path) )
          .to eql Sycamore::Tree[foo: {bar: :baz}]
        expect( Sycamore::Tree[foo: {bar: {baz: :more}}].add(path) )
          .to eql Sycamore::Tree[foo: {bar: {baz: :more}}]
      end

      it 'does not add an empty child at the path' do
        expect( Sycamore::Tree.new.add(path).child_at(path) ).to be_absent
        expect( Sycamore::Tree[foo: :bar].add(path).child_at(path) ).to be_absent
        expect( Sycamore::Tree[foo: {bar: :baz}].add(path).child_at(path) ).to be_absent
      end

      context 'edge cases' do
        it 'does nothing, when given an empty path' do
          expect( Sycamore::Tree[foo: :bar].add(Sycamore::Path[]) )
            .to eql Sycamore::Tree[foo: :bar]
        end
      end
    end

    context 'when given an Enumerable of Path objects' do
      it 'does add all paths' do
        expect( Sycamore::Tree.new.add(
            [ Sycamore::Path[:foo, :bar, :baz], Sycamore::Path[1,2,3] ]) )
          .to eql Sycamore::Tree[foo: {bar: :baz}, 1 => {2 => 3}]
      end
    end

    context 'when given an Enumerable of mixed objects' do
      it 'does add the elements appropriately' do
        expect( Sycamore::Tree.new.add(
          [ :foo, :bar, Sycamore::Path[:foo, :bar, :baz], {1=>2},
            Sycamore::Tree[1=>{2=>3}]]) )
          .to eql Sycamore::Tree[foo: {bar: :baz}, bar: nil, 1 => {2 => 3}]
      end
    end
  end

  ############################################################################

  describe '#replace' do
    it 'does clear the tree before adding the arguments' do
      expect( Sycamore::Tree[:foo].replace(:bar).nodes ).to eql [:bar]
      expect( Sycamore::Tree[:foo].replace([:bar, :baz]).nodes ).to eql %i[bar baz]
      expect( Sycamore::Tree[a: 1].replace(a: 2) ).to     include_tree(a: 2)
      expect( Sycamore::Tree[a: 1].replace(a: 2) ).not_to include_tree(a: 1)
      expect( Sycamore::Tree[a: 1].replace(Sycamore::Path[:foo, :bar]) )
          .to eql Sycamore::Tree[foo: :bar]
    end

    context 'edge cases' do
      specify { expect( Sycamore::Tree[:foo].replace(nil).nodes ).to eql [nil] }
      specify { expect( Sycamore::Tree[:foo].replace([]).nodes ).to be_empty }
      specify { expect( Sycamore::Tree[:foo].replace({}).nodes ).to be_empty }
      specify { expect( Sycamore::Tree[:foo].replace(Sycamore::Nothing).nodes ).to be_empty }
    end
  end

  ############################################################################

  describe '#[]=' do
    context 'when the node at the given path is present' do
      it 'does clear a child tree before adding the arguments to it' do
        tree = Sycamore::Tree[a: 1]
        expect { tree[:a] = 2      }.to change { tree[:a].node  }.from( 1 ).to(2)
        expect { tree[:a] = [3, 4] }.to change { tree[:a].nodes }.from([2]).to([3,4])

        tree = Sycamore::Tree[a: {b: 1}]
        expect { tree[:a] = :b }.to change { tree[:a, :b].nodes }.from([1]).to([])

        tree = Sycamore::Tree[a: {b: 2}]
        expect { tree[:a, :b] = [3, 4] }.to change { tree[:a, :b].nodes }.from([2]).to([3,4])

        tree = Sycamore::Tree[a: {b: 2}]
        expect { tree[:a, :b] = Sycamore::Path[3, 4] }
          .to change { tree }.to Sycamore::Tree[a: {b: {3=>4}}]
      end
    end

    context 'when the node at the given path is not present' do
      it 'does create the tree and add the arguments' do
        expect { tree[:a] = 1     }.to change { tree[:a].nodes }.from([]).to([1])
        expect { tree[:b, :c] = 1 }.to change { tree[:b, :c].nodes }.from([]).to([1])
      end
    end

    context 'when assigning Nothing' do
      context 'when the node at the given path is present' do
        it 'does remove a child' do
          tree = Sycamore::Tree[a: 1]
          expect { tree[:a] = Sycamore::Nothing }
            .to change { tree[:a].class }.from(Sycamore::Tree).to(Sycamore::Absence)
          expect( tree ).to eql Sycamore::Tree[:a]

          tree = Sycamore::Tree[a: {b: 1}]
          expect { tree[:a, :b] = Sycamore::Nothing }
            .to change { tree[:a, :b].class }.from(Sycamore::Tree).to(Sycamore::Absence)
          expect( tree ).to eql Sycamore::Tree[a: :b]
        end
      end

      context 'when the node at the given path is not present' do
        it 'does create the tree' do
          tree = Sycamore::Tree.new
          expect { tree[:a] = Sycamore::Nothing }.to change { tree }.from(Sycamore::Tree[]).to(Sycamore::Tree[:a])
          tree = Sycamore::Tree.new
          expect { tree[:b, :c] = Sycamore::Nothing }.to change { tree }.from(Sycamore::Tree[]).to(Sycamore::Tree[b: :c])
        end
      end
    end

    context 'when assigning nil' do
      context 'when the node at the given path is present' do
        it 'does remove a child' do
          tree = Sycamore::Tree[a: 1]
          expect { tree[:a] = nil }
            .to change { tree[:a].class }.from(Sycamore::Tree).to(Sycamore::Absence)
          expect( tree ).to eql Sycamore::Tree[:a]

          tree = Sycamore::Tree[a: {b: 1}]
          expect { tree[:a, :b] = nil }
            .to change { tree[:a, :b].class }.from(Sycamore::Tree).to(Sycamore::Absence)
          expect( tree ).to eql Sycamore::Tree[a: :b]
        end
      end

      context 'when the node at the given path is not present' do
        it 'does create the tree' do
          tree = Sycamore::Tree.new
          expect { tree[:a] = nil }.to change { tree }.from(Sycamore::Tree[]).to(Sycamore::Tree[:a])
          tree = Sycamore::Tree.new
          expect { tree[:b, :c] = nil }.to change { tree }.from(Sycamore::Tree[]).to(Sycamore::Tree[b: :c])
        end
      end

      it 'does assign a nil node, when assigning nil in an array' do
        tree = Sycamore::Tree[foo: :bar]
        tree[:foo] = [nil]
        expect( tree[:foo].nodes ).to contain_exactly nil
      end
    end

    context 'edge cases' do
      it 'does raise an error, when the given path is empty' do
        expect { tree[] = 42 }.to raise_error ArgumentError
      end

      it 'does treat nil as part of the path like any other value' do
        expect { tree[nil] = 1      }.to change { tree[nil].nodes }.from([]).to([1])
        expect { tree[nil, nil] = 1 }.to change { tree[nil, nil].nodes }.from([]).to([1])

        tree = Sycamore::Tree[nil => 1]
        expect { tree[nil] = 2 }.to change { tree[nil].node }.from(1).to(2)

        tree = Sycamore::Tree[nil => {nil => 2}]
        expect { tree[nil, nil] = [3, 4] }.to change { tree[nil, nil].nodes }.from([2]).to([3,4])
      end
    end
  end

end
