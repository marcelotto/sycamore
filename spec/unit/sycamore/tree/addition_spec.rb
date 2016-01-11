describe Sycamore::Tree do

  describe '#add*' do
    context 'when given a single atomic value' do
      it 'does add the value to the set of nodes' do
        expect( Sycamore::Tree.new << 1 ).to include_node 1
      end

      context 'when a given value is already present' do
        it 'does nothing' do
          expect( Sycamore::Tree[1].add(1).size ).to be 1
        end

        it 'does not overwrite the existing children' do
          expect( Sycamore::Tree[a: 1].add(:a) ).to include_tree(a: 1)
        end
      end

      it 'does nothing, when given nil' do
        expect( Sycamore::Tree.new << nil ).to be_empty
      end

      it 'does nothing, when given the Nothing tree' do
        expect( Sycamore::Tree.new << Sycamore::Nothing ).to be_empty
      end

      it 'does treat false as key like any other value' do
        expect( Sycamore::Tree.new << false).to include_node false
      end
    end

    context 'when given a single array' do
      it 'does add all values to the set of nodes' do
        expect( Sycamore::Tree.new << [1,2] ).to include_nodes 1, 2
      end

      it 'does ignore duplicates' do
        expect( Sycamore::Tree.new << [1,2,2,3,3,3] ).to include_nodes 1, 2, 3
      end

      it 'does ignore the nils' do
        tree = Sycamore::Tree.new

        tree.add([nil, :foo, nil, :bar])

        expect(tree).to include_nodes :foo, :bar
        expect(tree.size).to be 2
      end

      it 'does nothing, when all given values are nil' do
        expect( Sycamore::Tree.new << [nil, nil, nil] ).to be_empty
      end

      context 'when the array is nested' do
        it 'does treat hashes as nodes with children' do
          expect( Sycamore::Tree.new << [:a, b: 1]         ).to include_tree({a: nil, b: 1})
          expect( Sycamore::Tree.new << [:b,  a: 1, c: 2 ] ).to include_tree({a: 1, b: nil, c: 2})
          expect( Sycamore::Tree.new << [:b, {a: 1, c: 2}] ).to include_tree({a: 1, b: nil, c: 2})
          expect( Sycamore::Tree.new << [:a, b: {c: 2}   ] ).to include_tree({a: nil, b: {c: 2}})
        end

        it 'does merge the children of duplicate nodes' do
          expect( Sycamore::Tree.new << [1,{1=>2}] ).to include_tree({1=>2})
          expect( Sycamore::Tree.new << [1,{1=>2}, {1=>3}] ).to include_tree({1=>[2,3]})
          expect( Sycamore::Tree.new << [1,{1=>{2=>3}}, {1=>{2=>4}}] ).to include_tree({1=>{2=>[3,4]}})
        end

        it 'raises an error, when the nested enumerable is not Tree-like' do
          expect { Sycamore::Tree.new.add([1, [2, 3]]) }.to raise_error Sycamore::NestedNodeSet
        end
      end
    end

    context 'when given a single hash' do
      it 'does add a similar tree structure' do
        expect( Sycamore::Tree.new << { foo: :bar } ).to include_tree foo: :bar
      end

      it 'does treat false as key like any other value' do
        expect( Sycamore::Tree.new << {false => 1} ).to include_tree({false => 1})
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

  describe '#add_child' do

    describe 'child constructor integration' do
      let(:tree) { Sycamore::Tree.new }
      let(:subclass) { Class.new(Sycamore::Tree) }

      subject(:new_child) { tree.add_child(1, 2)[1] }

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


    context 'when the given node is nil' do
      subject { Tree[].add_child(nil, 42) }
      it { is_expected.to be_empty }
    end

    context 'when the given node is Nothing' do
      subject { Tree[].add_child(Sycamore::Nothing, 42) }
      it { is_expected.to be_empty }
    end

    # context 'when the given child is an Absence' do
    #   subject { Tree[].add_child(42, Tree[].child(:absent)) }
    #   it { is_expected.not_to be_empty }
    # end


    ###############
    # TODO: Refactor the following

    specify 'some examples for atoms' do
      tree = Sycamore::Tree.new

      tree.add_child(42, 3.14) # => {1 => 3.14}
      expect(tree).to include 42
      expect(tree.size).to be 1
      expect(tree.child_of(42)).to be_a Tree
      expect(tree.child_of(42)).not_to be_nothing
      expect(tree.child_of(42)).to include 3.14
      expect(tree.child_of(42).size).to be 1

      tree.add_child(42, 'text') # => {1 => [3.14, 'text']}
      expect(tree.size).to be 1
      expect(tree.child_of(42)).to include 'text'
      expect(tree.child_of(42).size).to be 2

      tree.add_child(1, nil)
      tree.add_child(42, Sycamore::Nothing) # => {1 => [3.14, 'text']}
      expect(tree.size).to be 2
      expect(tree.child_of(42).size).to be 2

    end


    specify 'some examples for arrays' do
      tree = Sycamore::Tree.new

      tree.add_child(:root, [2, 3]) # => {:root => [2, 3]}
      expect(tree).to include :root
      expect(tree.size).to be 1
      expect(tree.child_of(:root)).to be_a Sycamore::Tree
      expect(tree.child_of(:root)).not_to be_nothing
      expect(tree.child_of(:root)).to include 2
      expect(tree.child_of(:root)).to include 3
      # TODO: expect(tree.child(:root)).to include [2,3]
      expect(tree.child_of(:root).size).to be 2

      tree.add_child(:root, [3, 4, 0]) # => {:root => [2, 3, 4, 0]}
      expect(tree.size).to be 1
      expect(tree.child_of(:root)).to include 4
      expect(tree.child_of(:root)).to include 0
      # TODO: expect(tree.child(:root)).to include [3, 4]
      expect(tree.child_of(:root).size).to be 4

      tree.add_child(:root, []) # => {:root => [2, 3, 4, 0]}
      expect(tree.size).to be 1
      expect(tree.child_of(:root)).to include 4
      expect(tree.child_of(:root)).to include 0
      expect(tree.child_of(:root).size).to be 4

    end

    specify 'some examples when the node is false' do
      tree = Sycamore::Tree.new
      tree.add_child(false, :foo) # => {false => :foo}
      expect(tree.size).to be 1
      expect(tree.child_of(false)).to include :foo
      expect(tree.child_of(false).size).to be 1
    end

    specify 'some examples for hashes' do
      tree = Sycamore::Tree.new

      tree.add_child(:noah, {shem: :elam } ) # => {:noah => {:shem => :elam}}
      expect(tree).to include :noah
      expect(tree.size).to be 1
      expect(tree.child_of(:noah)).to be_a Sycamore::Tree
      expect(tree.child_of(:noah)).not_to be_nothing
      expect(tree.child_of(:noah)).to include :shem
      expect(tree.child_of(:noah).size).to be 1
      expect(tree.child_of(:noah).child_of(:shem)).to be_a Sycamore::Tree
      expect(tree.child_of(:noah).child_of(:shem)).not_to be_nothing
      expect(tree.child_of(:noah).child_of(:shem)).to include :elam
      expect(tree.child_of(:noah).child_of(:shem).size).to be 1

      tree.add_child(:noah, {shem: :asshur,
                             japeth: :gomer,
                             ham: [:cush, :mizraim, :put, :canaan] } )
      # => {:noah => {:shem   => [:elam, :asshur]}
      #              {:japeth => :gomer}
      #              {:ham    => [:cush, :mizraim, :put, :canaan]}}
      expect(tree.size).to be 1
      expect(tree[:noah].size).to be 3
      expect(tree[:noah]).to include :japeth
      expect(tree[:noah]).to include :ham
      expect(tree[:noah][:shem].size).to be 2
      expect(tree[:noah][:shem]).to include :elam
      expect(tree[:noah][:shem]).to include :asshur
      expect(tree[:noah][:japeth].size).to be 1
      expect(tree[:noah][:japeth]).to include :gomer
      expect(tree[:noah][:ham].size).to be 4
      expect(tree[:noah][:ham]).to include :cush
      expect(tree[:noah][:ham]).to include :mizraim
      expect(tree[:noah][:ham]).to include :put
      expect(tree[:noah][:ham]).to include :canaan

      tree << { noah: {shem: :asshur,
                       japeth: :gomer,
                       ham: [:cush, :mizraim, :put, :canaan] } }
      # => {:noah => {:shem   => [:elam, :asshur]}
      #              {:japeth => :gomer}
      #              {:ham    => [:cush, :mizraim, :put, :canaan]}}
      expect(tree.size).to be 1
      expect(tree[:noah].size).to be 3
      expect(tree[:noah]).to include :japeth
      expect(tree[:noah]).to include :ham
      expect(tree[:noah][:shem].size).to be 2
      expect(tree[:noah][:shem]).to include :elam
      expect(tree[:noah][:shem]).to include :asshur
      expect(tree[:noah][:japeth].size).to be 1
      expect(tree[:noah][:japeth]).to include :gomer
      expect(tree[:noah][:ham].size).to be 4
      expect(tree[:noah][:ham]).to include :cush
      expect(tree[:noah][:ham]).to include :mizraim
      expect(tree[:noah][:ham]).to include :put
      expect(tree[:noah][:ham]).to include :canaan

      tree.add_child(:noah, {})
      # => {:noah => {:shem   => [:elam, :asshur]}
      #              {:japeth => :gomer}
      #              {:ham    => [:cush, :mizraim, :put, :canaan]}}
      expect(tree.size).to be 1
      expect(tree.child_of(:noah).size).to be 3
      expect(tree.child_of(:noah).child_of(:shem).size).to be 2
      expect(tree.child_of(:noah).child_of(:japeth).size).to be 1
      expect(tree.child_of(:noah).child_of(:ham).size).to be 4

    end

    specify 'some examples for Trees' do
      tree = Sycamore::Tree.new

    end

=begin
    shared_examples 'for adding a given Atom-like child' do |options = {}|
      let(:initial) { options[:initial] or raise ArgumentError, 'No initial value given.' }
      let(:node)    { options[:node]    or raise ArgumentError, 'No node given.' }
      let(:child)   { options[:child]   or raise ArgumentError, 'No child given.' }

      # TODO: extract from below - Problem: no access to initial, nodes etc.
      # describe 'the added tree' do
      #   subject(:added_child) { tree_with_child.child(node) }
      #   it { is_expected.to be_a Tree }
      #   it { is_expected.to_not be Sycamore::Nothing }
      #   it { is_expected.to_not be tree_with_child }
      #   it { is_expected.to include child }
      #   it 'does add only the nodes of the given child, to the child of the new child tree' do
      #     expect(added_child.size).to be 1
      #   end
      # end
    end

    shared_examples 'for adding a given Collection-like child' do
    end

    shared_examples 'for adding a given Tree-like child' do
    end
=end

    subject(:tree) { Sycamore::Tree[initial] }

    let(:tree_with_child) { tree.add_child(node, child) }

    context 'when the given node is present' do

      context 'when the node does not have already child' do

        context 'when given an Atom-like child' do
          let(:initial) { [1] }
          let(:node)    { 1 }
          let(:child)   { 2 }


          # TODO: extract the general addition examples, independent from the state
          #         into a custom matcher
          # include_examples 'for adding a given Atom-like child',
          #                  initial: [1], node: 1, child: 2


          it { is_expected.to include node }

          describe 'the added tree' do
            subject(:added_child) { tree_with_child.child_of(node) }
            it { is_expected.to be_a Sycamore::Tree }
            it { is_expected.to_not be_nothing }
            it { is_expected.to include child }
            it 'does add only the nodes of the given child, to the child of the new child tree' do
              expect(added_child.size).to be 1
            end
          end

        end

        context 'when the node has already a child' do

          context 'when given an Atom-like child' do
            # include_examples 'for adding a given Atom-like child'
          end
          context 'when given a Collection-like child' do
            # include_examples 'for adding a given Collection-like child'
          end
          context 'when given a Tree-like child' do
            # include_examples 'for adding a given Tree-like child'
          end
        end


        context 'when given a Collection-like child' do
          # include_examples 'for adding a given Collection-like child'
        end
        context 'when given a Tree-like child' do
          # include_examples 'for adding a given Tree-like child'
        end
      end

    end

    # TODO: Should behave the same as 'when a node to the given atom is present'
    context 'when a node to the given atom is absent' do
      let(:initial) { [] }
      let(:node)    { 1 }
      let(:child)   { 2 }


      # TODO: extract the general addition examples, independent from the state
      #         into a custom matcher
      # include_examples 'for adding a given Atom-like child',
      #                  initial: [1], node: 1, child: 2


      it { is_expected.not_to include node }

      describe 'the added tree' do
        subject(:added_child) { tree_with_child.child_of(node) }
        it { is_expected.to be_a Sycamore::Tree }
        it { is_expected.to_not be_nothing }
        it { is_expected.to include child }
        it 'does add only the nodes of the given child, to the child of the new child tree' do
          expect(added_child.size).to be 1
        end
      end

    end

    context 'when the given atom is nil' do
      pending
    end

    context 'when the given atom is Nothing' do
      pending
    end

    context 'when the given atom is an Absence' do
      let(:tree) { Sycamore::Tree[] }
      subject { tree.add_child(:property, Tree[].child_of(42)) }
      it { is_expected.not_to be_empty }
      it { is_expected.to include :property }

      describe 'the child' do
        subject { tree[:property] }
        it { is_expected.to     be_absent }
        # it { is_expected.to     be_nothing }
        it { is_expected.not_to include 42 }
        it { is_expected.to     be_empty }
      end

    end



=begin
    context 'the given node is in the tree as a leaf' do
      let(:initial) { [1] }
      let(:node)    { 1 }
      let(:child)   { 2 }

      describe 'the added tree' do
        subject(:added_child) { tree_with_child.child(node) }
        it { is_expected.to be_a Tree }
        it { is_expected.to_not be Sycamore::Nothing }
        it { is_expected.to_not be tree_with_child }
        it { is_expected.to include child }
        it 'does add only the nodes of the given child, to the child of the new child tree' do
          expect(added_child.size).to be 1
        end
      end

    end
=end

    context 'the given node is not in the tree' do
      let(:initial) { [] }
      let(:node)    { 1 }
      let(:child)   { 2 }

      describe 'the added tree' do
        subject(:added_child) { tree_with_child.child_of(node) }
        it { is_expected.to be_a Sycamore::Tree }
        it { is_expected.to_not be_nothing }
        it { is_expected.to_not be tree_with_child }
        it { is_expected.to include child }
        it 'does add only the nodes of given the given child, to the child of the new child tree' do
          expect(added_child.size).to be 1
        end
      end
    end

    context 'when the given node is in this tree with an existing child tree' do
      let(:initial) { { 1 => 2 } }
      let(:node)    { 1 }
      let(:child)   { 3 }

      describe 'the added tree' do
        subject(:added_child) { tree_with_child.child_of(node) }

        it { is_expected.to be_a Sycamore::Tree }
        it { is_expected.to_not be_nothing }
        it { is_expected.to_not be tree_with_child } # TODO: Needed/Useful?
        it { is_expected.to include child }
        it { is_expected.to include 2 }

        it 'does add only the nodes of given the given child, to the child of the new child tree' do
          expect(added_child.size).to be 2
        end
      end
    end

  end

  ############################################################################

  describe '#add_children' do

    # shared_examples 'when given a flat tree-like structure' do
    #
    #   subject { Sycamore::Tree.new(initial).add_children(struct) }
    #
    #   context 'when nodes for certain keys are already present, but are leaves' do
    #     let(:initial) { 1 }
    #     let(:struct)  { {1 => 2} }
    #
    #     it 'creates a new tree, before adding the '
    #   end
    #
    #   context 'when nodes for certain keys are not present' do
    #     let(:initial) { [] }
    #     let(:struct)  { {1 => 2} }
    #
    #     it 'does add new nodes for keys of the struct, to which the value can be added as a child' do
    #
    #     end
    #   end
    #
    #   context 'when nodes for certain keys are already present and have children' do
    #     let(:initial) { {1 => 2} }
    #     let(:struct)  { {1 => 3} }
    #   end
    #
    # end

    context 'when Nothing given' do
      subject { Tree[].add_children(Sycamore::Nothing) }
      it { is_expected.to     be_empty }
    end

    context 'when Absence given' do
      subject { Tree[].add_children(Tree[].child_of(number)) }
      it { is_expected.to     be_empty }
    end

    context 'when given the empty hash' do
      subject { Tree[].add_children({}) }
      it      { is_expected.to be_empty }
    end

    specify { expect(Tree[a: 1]).to include(a: 1) }
    specify { expect(Tree[a: 1, b: 2]).to include(a: 1, b: 2) }
    specify { expect(Tree[a: 1, b: [2, 3]]).to include(a: 1, b: [2, 3]) }
    specify { expect(Tree[a: [1, 'foo'], b: {2 => 3}]).to include(a: [1, 'foo'], b: {2 => 3}) }

    specify { expect(Tree[1 => nil, 2 => nil, 3 => nil].leaves?(1,2,3)).to be true }
    specify { expect(Tree[1 => [], 2 => [], 3 => []].leaves?(1,2,3)).to be true }
    specify { expect(Tree[1 => {}, 2 => {}, 3 => {}].leaves?(1,2,3)).to be true }

  end

end
