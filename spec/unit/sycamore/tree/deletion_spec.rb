describe Sycamore::Tree do

  describe '#delete' do

    context 'when given a single atomic value' do
      it 'does delete the value from the set of nodes' do
        expect( Sycamore::Tree[1] >> 1 ).to be_empty
        expect( Sycamore::Tree[1,2,3].delete(2).nodes.to_set ).to eq Set[1,3]
        expect( Sycamore::Tree[:foo, :bar].delete(:foo).size ).to be 1
      end

      it 'does nothing, when the given value is not present' do
        expect( Sycamore::Tree[1   ].delete(2    ) ).to include_node 1
        expect( Sycamore::Tree[:foo].delete('foo') ).to include_node :foo
      end

      context 'edge cases' do
        it 'does nothing, when given nil' do
          expect( Sycamore::Tree[1].delete(nil) ).to include_node 1
        end

        it 'does nothing, when given the Nothing tree' do
          expect( Sycamore::Tree[1].delete(Sycamore::Nothing) ).to include_node 1
        end

        it 'does treat false as key like any other value' do
          expect( Sycamore::Tree[false].delete(false)).to be_empty
        end
      end
    end

    context 'when given a single array' do
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

        it 'raises an error, when the nested enumerable is not Tree-like' do
          expect { Sycamore::Tree.new.delete([1, [2, 3]]) }.to raise_error Sycamore::NestedNodeSet
        end
      end

      context 'edge cases' do
        it 'does nothing, when given an empty array' do
          expect( Sycamore::Tree[1,2,3].delete([]).nodes.to_set ).to eq Set[1,2,3]
        end
      end
    end

    context 'when given a single hash' do
      it 'does delete the given tree structure' do
        expect( Sycamore::Tree[a: 1].delete(a: 1) ).to be_empty

        expect( Sycamore::Tree[a: [1, 2]].delete(:a)   ).to     be_empty
        expect( Sycamore::Tree[a: [1, 2]].delete(a: 2) ).not_to include_tree a: 2
        expect( Sycamore::Tree[a: [1, 2]].delete(a: 2) ).to     include_tree a: 1

        expect( Sycamore::Tree[a: [1, 2]].delete(a: 1, a: 2) ).to include_node :a

        expect( Sycamore::Tree[a: 1, b: 2].delete(:a)  ).not_to include_tree a: 1
        expect( Sycamore::Tree[a: 1, b: 2].delete(:a)  ).to     include_tree b: 2

        expect( Sycamore::Tree[a: 1, b: [2, 3]].delete(a: 1, b: 2) === {b: 3}).to be true
      end

      context 'with null values'

      context 'edge cases' do
        it 'does treat false as key like any other value' do
          expect( Sycamore::Tree[false => 1].delete(false => 1) ).to be_empty
        end

        it 'does nothing, when given an empty hash' do
          expect( Sycamore::Tree.new >> {} ).to be_empty
        end

      end
    end

    context 'when given another tree' do

      pending

      context 'edge cases' do
        it 'does nothing, when given an absent tree' do
          absent_tree = Sycamore::Tree.new.child_of(42)
          expect( Sycamore::Tree[42].delete(absent_tree) ).to include_node 42
        end
      end
    end

    context 'when given multiple arguments' do
      context 'when all arguments are atomic'
      context 'when all arguments are atomic or tree-like'
      context 'when some arguments are non-tree-like enumerables'
    end

  end

  ############################################################################

  describe '#clear' do
    it 'does nothing when empty' do
      expect( Sycamore::Tree.new.clear.size  ).to be 0
      expect( Sycamore::Tree.new.clear.nodes ).to eq []
    end

    it 'does delete all nodes and their children' do
      expect( Sycamore::Tree[1, 2      ].clear.size  ).to be 0
      expect( Sycamore::Tree[:foo, :bar].clear.nodes ).to eq []
    end
  end

end
