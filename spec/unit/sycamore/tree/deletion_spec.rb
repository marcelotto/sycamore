describe Sycamore::Tree do

  describe '#delete' do

    context 'when given a single node' do
      it 'does delete the value from the set of nodes' do
        expect( Sycamore::Tree[1] >> 1 ).to be_empty
        expect( Sycamore::Tree[1,2,3].delete(2).nodes.to_set ).to eql Set[1,3]
        expect( Sycamore::Tree[:foo, :bar].delete(:foo).size ).to be 1
      end

      it 'does nothing, when the given value is not present' do
        expect( Sycamore::Tree[1   ].delete(2    ) ).to include_node 1
        expect( Sycamore::Tree[:foo].delete('foo') ).to include_node :foo
      end

      context 'edge cases' do
        it 'does nothing, when given the Nothing tree' do
          expect( Sycamore::Tree[1].delete(Sycamore::Nothing) ).to include_node 1
        end

        it 'does treat nil like any other value' do
          expect( Sycamore::Tree[nil].delete(nil)).to be_empty
        end

        it 'does treat false like any other value' do
          expect( Sycamore::Tree[false].delete(false)).to be_empty
        end
      end
    end

    context 'when given an array' do
      it 'does delete the values from the set of nodes that are present' do
        expect( Sycamore::Tree[1,2,3] >> [1,2,3] ).to be_empty
        expect( Sycamore::Tree[1,2,3] >> [2,3  ] ).to include 1
        expect( Sycamore::Tree[1,2,3].delete([2,3]).size ).to be 1
      end

      it 'does ignore the values that are not present' do
        expect( Sycamore::Tree.new  >> [1,2] ).to be_empty
        expect( Sycamore::Tree[1,2] >> [2,3] ).to include 1
        expect( Sycamore::Tree[1,2].delete([2,3]).size ).to be 1
      end

      context 'when the array is nested' do
        it 'does treat hashes as nodes with children' do
          expect( Sycamore::Tree[a: 1, b: 2     ].delete([:a, b: 2]) ).to be_empty
          expect( Sycamore::Tree[a: 1, b: [2, 3]].delete([:a, b: 2]) === {b: 3} ).to be true
        end
      end

      context 'when the array contains a nested enumerable that is not Tree-like' do
        it 'raises an error' do
          expect { Sycamore::Tree.new.delete([1, [2, 3]]) }.to raise_error Sycamore::InvalidNode
        end

        it 'does not change the tree' do
          tree = Sycamore::Tree[1,2]
          expect { tree.delete([1, [2, 3]]) }.to raise_error Sycamore::InvalidNode
          expect( tree.nodes ).to contain_exactly 1, 2
        end
      end

      context 'edge cases' do
        it 'does nothing, when given an empty array' do
          expect( Sycamore::Tree[1,2,3].delete([]).nodes.to_set ).to eql Set[1,2,3]
        end

        it 'does treat nil like any other value' do
          expect( Sycamore::Tree[1, 2, nil].delete([nil, 1]).nodes ).to eql [2]
        end
      end
    end

    DELETE_TREE_EXAMPLES = [
      { before: {a: 1}           , delete: {a: 1}     , after: {} },
      { before: {a: [1, 2]}      , delete: {a: 2}     , after: {a: 1} },
      { before: {a: [1, 2]}      , delete: {a: [2]}   , after: {a: 1} },
      { before: {a: 1, b: [2,3]} , delete: {a:1, b:2} , after: {b: 3} },
      { before: {a: 1}           , delete: {a: Sycamore::Tree[1]} , after: {} },
      { before: {a: [1, 2]}      , delete: {a: Sycamore::Tree[2]} , after: {a: 1} },
    ]

    NOT_DELETE_TREE_EXAMPLES = [
      { before: {a: 1}           , delete: {a: 2} },
      { before: {a: [1, 2]}      , delete: {a: 3} },
      { before: {a: [1, 2]}      , delete: {a: [3]} },
      { before: {a: 1, b: [2,3]} , delete: {a:2, b:4} },
      { before: {a: [1, 2]}      , delete: {a: Sycamore::Tree[3]} },
      { before: {a: 1}           , delete: {a: {1 => 2}} },
    ]

    PARTIAL_DELETE_TREE_EXAMPLES = [
      { before: {a: [1, 2]}      , delete: {a: [2, 3]} , after: {a: 1} },
      { before: {a: 1, b: [2,3]} , delete: {c:1, b:2}  , after: {a:1, b:3} },
    ]

    context 'when given a hash' do
      it 'does delete the given tree structure' do
        DELETE_TREE_EXAMPLES.each do |example|
          expect( Sycamore::Tree[example[:before]].delete(example[:delete]) )
            .to eql Sycamore::Tree[example[:after]]
        end
      end

      it 'does nothing, when given something not part of the tree' do
        NOT_DELETE_TREE_EXAMPLES.each do |example|
          expect( Sycamore::Tree[example[:before]].delete(example[:delete]) )
            .to eql Sycamore::Tree[example[:before]]
        end
      end

      it 'does delete the existing paths and ignore the not existing paths of given input data' do
        PARTIAL_DELETE_TREE_EXAMPLES.each do |example|
          expect( Sycamore::Tree[example[:before]].delete(example[:delete]) )
            .to eql Sycamore::Tree[example[:after]]
        end
      end

      context 'when given a tree with an enumerable key' do
        it 'raises an error' do
          expect { Sycamore::Tree.new.delete([1,2] => 3) }.to raise_error Sycamore::InvalidNode
          expect { Sycamore::Tree.new.delete({1 => 2} => 3) }.to raise_error Sycamore::InvalidNode
          expect { Sycamore::Tree.new.delete(Sycamore::Tree[1] => 42) }.to raise_error Sycamore::InvalidNode
          expect { Sycamore::Tree.new.delete(Sycamore::Nothing => 42) }.to raise_error Sycamore::InvalidNode
        end

        it 'does not change the tree' do
          tree = Sycamore::Tree[:foo, 1]
          expect { tree.delete([foo: :bar, [1,2] => 3]) }.to raise_error Sycamore::InvalidNode
          expect( tree.nodes ).to contain_exactly :foo, 1
        end
      end

      context 'edge cases' do
        it 'does nothing, when given an empty hash' do
          expect( Sycamore::Tree.new >> {} ).to be_empty
        end

        it 'does treat false as a key like any other value' do
          expect( Sycamore::Tree[false => :foo].delete(false => :foo) ).to be_empty
        end

        it 'does treat nil as a key like any other value' do
          expect( Sycamore::Tree[nil => :foo].delete(nil => :foo) ).to be_empty
        end

        it 'does treat nil as an element of the child tree like any other value' do
          expect( Sycamore::Tree[1 => [2, nil]].delete(1 => [nil]) ).to eql Sycamore::Tree[1=>2]
          expect( Sycamore::Tree[1 => [2, nil]].delete(1 => [nil, 2]) ).to be_empty
          expect( Sycamore::Tree[1 => {nil => 2}].delete(1 => {nil => 2}) ).to be_empty
        end

        it 'does ignore null values as children' do
          expect(Sycamore::Tree[1 => 2].delete({1 => {}})).to be_empty
          expect(Sycamore::Tree[1     ].delete({1 => []})).to be_empty
          expect(Sycamore::Tree[1 => 2].delete({1 => Sycamore::Nothing})).to be_empty
          expect(Sycamore::Tree[1 => 2].delete({1 => nil})).to be_empty
          expect(Sycamore::Tree[1 => nil].delete({1 => nil})).to be_empty
        end
      end
    end

    context 'when given a tree' do
      it 'does delete the given tree structure' do
        DELETE_TREE_EXAMPLES.each do |example|
          expect( Sycamore::Tree[example[:before]]
                    .delete(Sycamore::Tree[example[:delete]]) )
            .to eql Sycamore::Tree[example[:after]]
        end
      end

      context 'edge cases' do
        it 'does nothing, when given an empty tree' do
          expect( Sycamore::Tree[42] >> Sycamore::Tree.new ).to eql Sycamore::Tree[42]
        end

        context 'when given an Absence' do
          let(:absent_tree) { Sycamore::Tree.new.child_of(:something) }

          it 'does ignore it, when it is absent' do
            expect( Sycamore::Tree[:something].delete absent_tree ).to include :something
            expect( Sycamore::Tree[foo: :something].delete(foo: absent_tree)).to be_empty
          end

          it 'does treat it like a normal tree, when it was created' do
            absent_tree << 42

            expect( Sycamore::Tree[42].delete absent_tree ).to be_empty
            expect( Sycamore::Tree[foo: 42].delete(foo: absent_tree)).to be_empty
            expect( Sycamore::Tree[foo: [42, 3.14]].delete(foo: absent_tree)).to eql Sycamore::Tree[foo: 3.14]
          end
        end

        it 'does ignore null values as children' do
          expect(Sycamore::Tree[1 => 2].delete(Sycamore::Tree[1 => Sycamore::Nothing])).to be_empty
          expect(Sycamore::Tree[1 => 2].delete(Sycamore::Tree[1 => nil])).to be_empty
          expect(Sycamore::Tree[1 => 2].delete(Sycamore::Tree[1 => {}])).to be_empty
          expect(Sycamore::Tree[1     ].delete(Sycamore::Tree[1 => []])).to be_empty
        end
      end
    end

    context 'when given a single Path object' do
      let(:path) { Sycamore::Path[:foo, :bar, :baz] }

      it 'does delete the node at the given path and all other nodes on the path unless there are remaining children' do
        expect( Sycamore::Tree[foo: { bar: [:baz, 42], qux: nil}].delete(path) )
          .to eql Sycamore::Tree[foo: { bar: 42, qux: nil}]
        expect( Sycamore::Tree[foo: { bar: :baz, qux: nil}].delete(path) )
          .to eql Sycamore::Tree[foo: { qux: nil }]
        expect( Sycamore::Tree[foo: { bar: :baz}].delete(path) ).to be_empty
      end

      it 'does nothing when the path does not exist on the tree' do
        tree = Sycamore::Tree[1 => {2 => 3}]
        expect( tree.delete(path) ).to eql tree
      end

      it 'does nothing, when given an empty path' do
        tree = Sycamore::Tree[1 => {2 => 3}]
        expect( tree.delete(Sycamore::Path[]) ).to eql tree
      end
    end

    context 'when given multiple path objects' do
      it 'does delete the nodes at all given paths and all other nodes on the paths unless there are remaining children' do
        expect( Sycamore::Tree[foo: { bar: [:baz, 42], qux: nil}]
                  .delete([Sycamore::Path[:foo, :bar, :baz],
                          Sycamore::Path[:foo, :qux],
                          Sycamore::Path[:missing]]) )
          .to eql Sycamore::Tree[foo: { bar: 42}]
      end
    end

    context 'when given an Enumerable of mixed objects' do
      it 'does delete the elements appropriately' do
        expect( Sycamore::Tree[foo: { bar: [:baz, 42], qux: [1,2]}, more: nil]
                  .delete([:more, Sycamore::Path[:foo, :bar, 42],
                           {foo: {qux: 1}}, Sycamore::Tree[foo: {qux: 2}] ]) )
          .to eql Sycamore::Tree[foo: { bar: :baz}]
      end
    end
  end

  ############################################################################

  describe '#clear' do
    it 'does nothing when empty' do
      expect( Sycamore::Tree.new.clear.size  ).to be 0
      expect( Sycamore::Tree.new.clear.nodes ).to eql []
    end

    it 'does delete all nodes and their children' do
      expect( Sycamore::Tree[1, 2      ].clear.size  ).to be 0
      expect( Sycamore::Tree[:foo, :bar].clear.nodes ).to eql []
    end
  end

  ############################################################################

  describe '#compact' do
    it 'does not change a tree without empty child trees' do
      tree = Sycamore::Tree[1, foo: :bar]
      org_tree = tree.dup
      expect(tree.compact).to eql org_tree
    end

    it 'does delete all empty child trees' do
      expect( Sycamore::Tree[1=>[]].compact.child_of(1)).to be_absent
      expect( Sycamore::Tree[{1=>{},2=>{3=>{}}}].compact[1]).to be_absent
      expect( Sycamore::Tree[{1=>{},2=>{3=>{}}}].compact[2,3]).to be_absent
    end
  end
end
