describe Sycamore::Tree do

  describe 'child constructor integration' do
    let(:tree) { Sycamore::Tree.new }
    let(:subclass) { Class.new(Sycamore::Tree) }

    subject(:new_child) { tree.add(1 => 2)[1] }

    context 'when no child constructor defined' do
      it { is_expected.to eql Sycamore::Tree[2] }

      context 'on a subclass' do
        let(:tree) { subclass.new }
        it { is_expected.to eql subclass.with(2) }
      end
    end

    context 'when a child constructor defined' do

      context 'when a child Tree class defined' do
        let(:tree_class) { Class.new(Sycamore::Tree) }

        before(:each) { tree.child_constructor = tree_class }

        it { is_expected.to eql tree_class.with(2) }

        context 'on a subclass' do
          let(:tree) { subclass.new }
          it { is_expected.to eql tree_class.with(2) }
        end
      end

      context 'when a child prototype Tree instance defined' do
        pending 'Tree#clone'
      end

      context 'when a child constructor Proc defined' do
        before(:each) do
          tree.def_child_generator { Sycamore::Tree[42] }
        end

        it { is_expected.to be === Sycamore::Tree[42, 2] }

        context 'on a subclass' do
          let(:tree) { subclass.new }
          it { is_expected.to be === subclass[42, 2] }
        end
      end
    end
  end

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

end
