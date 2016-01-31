describe Sycamore::Tree do

  subject(:tree) { Sycamore::Tree.new }

  ############################################################################

  describe '#create_child' do
    it 'does add the given node' do
      expect( tree.create_child(:foo) ).to include_node :foo
    end

    it 'does add an empty tree as a child of the given node' do
      expect( tree.create_child(:foo).child_of(:foo) ).to be_a Sycamore::Tree
      expect( tree.create_child(:foo).child_of(:foo) ).not_to be Sycamore::Nothing
      expect( tree.create_child(:foo).child_of(:foo) ).not_to be_absent
      expect( tree.create_child(:foo).child_of(:foo) ).to be_empty

      expect( Sycamore::Tree[:foo].create_child(:foo).child_of(:foo) ).to be_a Sycamore::Tree
      expect( Sycamore::Tree[:foo].create_child(:foo).child_of(:foo) ).not_to be Sycamore::Nothing
      expect( Sycamore::Tree[:foo].create_child(:foo).child_of(:foo) ).not_to be_absent
      expect( Sycamore::Tree[:foo].create_child(:foo).child_of(:foo) ).to be_empty
    end

    it 'does nothing, when the given node is already present' do
      tree = Sycamore::Tree[foo: :bar]
      expect { tree.create_child(:foo) }.not_to change { tree.child_of(:foo) }
    end

    context 'edge cases' do
      it 'does raise an IndexError, when given nil' do
        expect { tree.create_child(nil) }.to raise_error IndexError
      end
    end
  end

  ############################################################################

  describe '#add' do
    context 'when given a single atomic value' do
      it 'does add the value to the set of nodes' do
        expect( Sycamore::Tree.new.add 1 ).to include_node 1
      end

      context 'when a given value is already present' do
        it 'does nothing' do
          expect( Sycamore::Tree[1].add(1).size ).to be 1
        end

        it 'does not overwrite the existing children' do
          expect( Sycamore::Tree[a: 1].add(:a) ).to include_tree(a: 1)
        end
      end

      context 'edge cases' do
        it 'does nothing, when given nil' do
          expect( Sycamore::Tree.new.add nil ).to be_empty
        end

        it 'does nothing, when given the Nothing tree' do
          expect( Sycamore::Tree.new.add Sycamore::Nothing ).to be_empty
        end

        it 'does treat false as key like any other value' do
          expect( Sycamore::Tree.new.add false).to include_node false
        end
      end
    end

    context 'when given a single array' do
      it 'does add all values to the set of nodes' do
        expect( Sycamore::Tree.new.add [1,2] ).to include_nodes 1, 2
      end

      it 'does merge the values with the existing nodes' do
        expect( Sycamore::Tree[1,2].add([2,3]).nodes.to_set ).to eq Set[1,2,3]
      end

      it 'does ignore duplicates' do
        expect( Sycamore::Tree.new.add [1,2,2,3,3,3] ).to include_nodes 1, 2, 3
        expect( Sycamore::Tree.new.add(['foo', 'bar', 'baz', 'foo', 'bar']).nodes.to_set).to eq %w[baz foo bar].to_set
      end

      context 'when the array is nested' do
        it 'does treat hashes as nodes with children' do
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

        it 'raises an error, when the nested enumerable is not Tree-like' do
          expect { Sycamore::Tree.new.add([1, [2, 3]]) }.to raise_error Sycamore::NestedNodeSet
        end
      end

      context 'edge cases' do
        it 'does ignore the nils' do
          expect( Sycamore::Tree.new.add([nil, :foo, nil, :bar]).nodes.to_set).to eq %i[foo bar].to_set
        end

        it 'does nothing, when all given values are nil' do
          expect( Sycamore::Tree.new.add [nil, nil, nil] ).to be_empty
        end

        it 'does nothing, when given an empty array' do
          expect( Sycamore::Tree.new.add [] ).to be_empty
        end
      end
    end

    context 'when given a hash' do
      it 'does add a similar tree structure' do
        expect( Sycamore::Tree.new << { foo: :bar } ).to include_tree foo: :bar
        expect( Sycamore::Tree.new << { foo: [:bar, :baz] } ).to include_tree foo: [:bar, :baz]
        expect( Sycamore::Tree.new << { a: 1, b: 2 } ).to include_tree a: 1, b: 2
        expect( Sycamore::Tree.new << { a: 1, b: [2,3] } ).to include_tree a: 1, b: [2,3]
        expect( Sycamore::Tree.new << { a: [1, 'foo'], b: {2 => 3} } )
          .to include_tree a: [1, 'foo'], b: {2 => 3}
        expect( Sycamore::Tree.new << { noah: { shem: :elam } } )
          .to include_tree noah: { shem: :elam }
      end

      it 'does merge the hash with the existing tree structure' do
        expect( Sycamore::Tree[foo: [1,2]].add(foo: [2,3]) ).to include_tree foo: [1,2,3]
        expect( Sycamore::Tree[foo: {1=>2}].add(foo: {1=>3}) ).to include_tree foo: {1=>[2,3]}
        expect( Sycamore::Tree[noah: { shem: :elam }].add(
                          noah: {shem: :asshur,
                                 japeth: :gomer,
                                 ham: [:cush, :mizraim, :put, :canaan] })
        ).to include_tree noah: {:shem   => [:elam, :asshur]}
                                {:japeth => :gomer}
                                {:ham    => [:cush, :mizraim, :put, :canaan]}
      end

      context 'with null values' do
        pending 'Ticket: support empty child trees'
        specify { expect(Sycamore::Tree.new.add([1 => Sycamore::Nothing, 2 => Sycamore::Nothing]).leaves?(1,2)).to be true }
        specify { expect(Sycamore::Tree.new.add([1 => nil, 2 => nil]).leaves?(1,2)).to be true }
        specify { expect(Sycamore::Tree.new.add([1 => [], 2 => []]).leaves?(1,2)).to be true }
        specify { expect(Sycamore::Tree.new.add([1 => {}, 2 => {}]).leaves?(1,2)).to be true }
      end

      context 'edge cases' do
        it 'does treat false as key like any other value' do
          expect( Sycamore::Tree.new.add(false => 1) ).to include_tree({false => 1})
        end

        it 'does nothing, when given an empty hash' do
          expect( Sycamore::Tree.new << {} ).to be_empty
        end

        it 'does nothing, when the key is nil' do
          expect( Sycamore::Tree.new << {nil => 42} ).to be_empty
        end

        it 'does nothing, when the key is the Nothing tree' do
          expect( Sycamore::Tree.new << {Sycamore::Nothing => 42} ).to be_empty
        end
      end
    end

    context 'when given another tree' do

      pending

      context 'edge cases' do
        it 'does nothing, when given an absent tree' do
          absent_tree = Sycamore::Tree.new.child_of(:missing)
          expect( Sycamore::Tree.new.add absent_tree ).to be_empty
        end
      end
    end

    context 'when given multiple arguments' do
      context 'when all arguments are atomic' do
        it 'does add all values to the set of nodes' do
          pending 'Can/should we support multiple arguments?'
          expect( Sycamore::Tree.new.add(1, 2) ).to include_nodes 1, 2
        end
      end
      context 'when all arguments are atomic or tree-like'
      context 'when some arguments are non-tree-like enumerables'
    end

  end

  ############################################################################

  describe '#replace' do
    it 'does clear the tree before adding the arguments' do
      expect( Sycamore::Tree[:foo].replace(nil) ).to be_empty
      expect( Sycamore::Tree[:foo].replace(:bar).nodes ).to eq [:bar]
      expect( Sycamore::Tree[:foo].replace([:bar, :baz]).nodes ).to eq %i[bar baz]
      expect( Sycamore::Tree[a: 1].replace(a: 2) ).to     include_tree(a: 2)
      expect( Sycamore::Tree[a: 1].replace(a: 2) ).not_to include_tree(a: 1)
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
      end
    end

    context 'when the node at the given path is not present' do
      it 'does create the tree and add the arguments' do
        expect { tree[:a] = 1     }.to change { tree[:a].nodes }.from([]).to([1])
        expect { tree[:b, :c] = 1 }.to change { tree[:b, :c].nodes }.from([]).to([1])
      end
    end

    context 'edge cases' do
      it 'does raise an ArgumentError, when the given path is empty' do
        expect { tree[] = 42 }.to raise_error ArgumentError
      end

      it 'does raise an IndexError, when the given path contains nil' do
        expect { tree[nil] = 42    }.to raise_error IndexError
        expect { tree[nil, 1] = 42 }.to raise_error IndexError
        expect { tree[1, nil] = 42 }.to raise_error IndexError
      end
    end

  end

end
