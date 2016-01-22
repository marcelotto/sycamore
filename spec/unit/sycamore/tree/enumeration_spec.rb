describe Sycamore::Tree do

  describe '#each_node' do
    context 'when a block given' do
      it 'does yield the block with each node as an argument' do
        expect { |b| Sycamore::Tree[1, 2, 3  ].each_node(&b) }.to yield_successive_args(1, 2, 3)
        expect { |b| Sycamore::Tree[foo: :bar].each_node(&b) }.to yield_successive_args(:foo)
      end
    end

    context 'when no block given' do
      it 'does return an enumerator' do
        expect( Sycamore::Tree[1].each_node ).to be_a Enumerator
      end

      it 'does return an enumerator over the nodes' do
        expect( Sycamore::Tree[1, 2=>3].each_node.to_a ).to eql [1, 2]
      end
    end
  end

  ############################################################################

  describe '#each_pair' do
    context 'when a block given' do
      it 'does yield the block with each node-child-pairs as an argument' do
        expect { |b| Sycamore::Tree[foo: :bar].each(&b) }
          .to yield_successive_args([:foo, Sycamore::Tree[:bar]])
        expect { |b| Sycamore::Tree[1=>2, 3=>[4, 5]].each(&b) }
          .to yield_successive_args([1, Sycamore::Tree[2]], [3, Sycamore::Tree[4, 5]])
      end

      it 'does yield nil as the child of leaves' do
        expect { |b| Sycamore::Tree[1, 2, 3].each(&b) }
          .to yield_successive_args([1, nil], [2, nil], [3, nil])
        expect { |b| Sycamore::Tree[1, 4=>5].each(&b) }
          .to yield_successive_args([1, nil], [4, Sycamore::Tree[5]])
      end
    end

    context 'when no block given' do
      it 'does return an enumerator' do
        expect( Sycamore::Tree[1].each ).to be_a Enumerator
      end

      it 'does return an enumerator over the node-child-pairs' do
        expect( Sycamore::Tree[1, 2=>3].each.to_a ).to eql [[1, nil], [2, Sycamore::Tree[3]]]
      end
    end
  end

  ############################################################################

  describe '#each_path' do
    context 'when a block given' do
      it 'does yield the block with the paths to each leaf of the complete tree' do
        expect{ |b| Sycamore::Tree[42    ].each_path(&b) }.to yield_successive_args Sycamore::Path[42]
        expect{ |b| Sycamore::Tree[1, 2  ].each_path(&b) }.to yield_successive_args Sycamore::Path[1], Sycamore::Path[2]
        expect{ |b| Sycamore::Tree[1 => 2].each_path(&b) }.to yield_successive_args Sycamore::Path[1, 2]
        expect{ |b| Sycamore::Tree[1 => { 2 => [3, 4] }].each_path(&b) }
          .to yield_successive_args Sycamore::Path[1, 2, 3], Sycamore::Path[1, 2, 4]
      end
    end

    context 'when no block given' do
      it 'does return an enumerator' do
        expect( Sycamore::Tree[1].each_path ).to be_a Enumerator
      end

      it 'does return an enumerator with the node-child-pairs' do
        expect(Sycamore::Tree[1     ].paths.to_a ).to eq [Sycamore::Path[1]]
        expect(Sycamore::Tree[1, 2  ].paths.to_a ).to eq [Sycamore::Path[1], Sycamore::Path[2]]
        expect(Sycamore::Tree[1 => 2].paths.to_a ).to eq [Sycamore::Path[1, 2]]
        expect(Sycamore::Tree[1 => { 2 => [3, 4] }].paths.to_a )
          .to eq [Sycamore::Path[1, 2, 3], Sycamore::Path[1, 2, 4]]
      end
    end
  end

end
