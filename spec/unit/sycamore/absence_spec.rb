describe Sycamore::Absence do

  let(:parent_tree) { Sycamore::Tree.new }
  let(:parent_node) { :missing }

  let(:absent_tree) { Sycamore::Absence.new(parent_tree, parent_node) }

  # let(:tree_with_leaf) { Sycamore::Tree[1] }
  # let(:absence_of_child) { Sycamore::Absence.new(tree_with_leaf, 1) }
  # let(:nested_absence_of_child) { Sycamore::Absence.new(absence_of_child, :nested_missing) }


  describe '#presence' do
    context 'when the absent tree has not been created' do
      it 'does return the Nothing tree' do
        expect( absent_tree.presence ).to be Sycamore::Nothing
      end
    end

    context 'when the absent tree has been created' do
      before(:each) { absent_tree.add :something }

      it 'does return the created tree' do
        expect( absent_tree.presence ).to be_a Sycamore::Tree
        expect( absent_tree.presence ).not_to be Sycamore::Nothing
        expect( absent_tree.presence ).not_to be_a Sycamore::Absence
      end
    end
  end

  ############################################################################
  # Absence and Nothing predicates
  ############################################################################

  describe '#nothing?' do
    context 'when the absent tree has not been created' do
      specify { expect( absent_tree.nothing? ).to be false }
    end

    context 'when the absent tree has been created' do
      before(:each) { absent_tree.add :something }

      specify { expect( absent_tree.nothing? ).to be false }
    end
  end

  describe '#absent?' do
    context 'when the absent tree has not been created' do
      specify { expect( absent_tree.absent? ).to be true }
    end

    context 'when the absent tree has been created' do
      context 'when it is blank' do
        before(:each) { absent_tree.add nil }

        specify { expect( absent_tree.absent? ).to be false }
      end

      context 'when it contains data' do
        before(:each) { absent_tree.add :something }

        specify { expect( absent_tree.absent? ).to be false }
      end
    end
  end

  describe '#present?' do
    context 'when the absent tree has not been created' do
      specify { expect( absent_tree.present? ).to be false }
    end

    context 'when the absent tree has been created' do
      context 'when it is blank' do
        before(:each) { absent_tree.add nil }
        specify { expect( absent_tree.present? ).to be false }
      end
      context 'when it contains data' do
        before(:each) { absent_tree.add :something }
        specify { expect( absent_tree.present? ).to be true }
      end
    end
  end


  ############################################################################
  # command methods
  ############################################################################

  COMMAND_METHODS_RETURN_SPECIAL_CASES = [:[]=]

  shared_examples_for 'with and without the parent node' do
    context 'when the node is present, but the child tree absent' do
      before(:each) { present_root_tree << parent_node }

      include_examples 'direct and nested absence'
    end

    context 'when the node and child tree are absent' do
      include_examples 'direct and nested absence'
    end
  end

  shared_examples_for 'direct and nested absence' do
    context 'when the parent is present' do
      let(:parent_tree) { present_root_tree }

      it_behaves_like 'every command method call'
    end

    context 'when the parent itself is absent' do
      let(:parent_tree) { Sycamore::Absence.new(present_root_tree, root_node) }
      let(:parent_node) { :other_missing }

      it_behaves_like 'every command method call'

      it 'does add the absent parent to the root tree' do
        method_call.call

        expect( present_root_tree )
          .to include_tree( root_node => { parent_node => absent_tree} )
      end
    end
  end

  shared_examples_for 'every command method call' do
    it 'does create and return a real tree' do
      unless COMMAND_METHODS_RETURN_SPECIAL_CASES.include? command_method_name
        created_tree = method_call.call

        expect( created_tree ).to be_a Sycamore::Tree
        expect( created_tree ).not_to be absent_tree
        expect( created_tree ).not_to be_a Sycamore::Absence
        expect( created_tree ).to be absent_tree.presence
      end
    end

    it 'does add the created tree to the parent tree' do
      method_call.call

      expect( parent_tree )
        .to include_tree( parent_node => absent_tree )
    end

    # it 'does delegate the command method call to the created tree' do
    #   skip 'Can we specify this in general?'
    # end
  end

  shared_examples_for 'command method calls under different circumstances' do |command_method, *args|
    let(:command_method_name) { command_method }
    let(:method_call) do
      proc { absent_tree.send(command_method, *args) }
    end

    let(:present_root_tree) { Sycamore::Tree.new }
    let(:root_node)         { :missing }
    let(:parent_node)       { root_node }
    let(:absent_tree)       { Sycamore::Absence.new(parent_tree, parent_node) }

    include_examples 'with and without the parent node'
  end


  describe '#add' do
    include_examples 'command method calls under different circumstances', :add, :foo
    include_examples 'command method calls under different circumstances', :add, nil
    include_examples 'command method calls under different circumstances', :add, Sycamore::Nothing

    it 'does execute the #add on the created tree' do
      expect( absent_tree.add(:foo)          ).to include_node :foo
      expect( absent_tree[:nested].add(:foo) ).to include_node :foo
    end
  end

  describe '#replace' do
    include_examples 'command method calls under different circumstances', :replace, :foo
    include_examples 'command method calls under different circumstances', :replace, nil
    include_examples 'command method calls under different circumstances', :replace, Sycamore::Nothing

    it 'does execute the #replace on the created tree' do
      expect( absent_tree.replace(:foo) ).to include_node :foo
    end
  end

  describe '#[]=' do
    include_examples 'command method calls under different circumstances', :[]=, :foo, :bar
    include_examples 'command method calls under different circumstances', :[]=, :foo, nil
    include_examples 'command method calls under different circumstances', :[]=, :foo, Sycamore::Nothing

    it 'does execute the #[]= on the created tree' do
      absent_tree[:foo] = :bar

      expect( absent_tree.presence ).to include_tree foo: :bar
    end
  end

  describe '#freeze' do
    include_examples 'command method calls under different circumstances', :freeze

    it 'does execute the #freeze on the created tree' do
      expect( absent_tree.freeze ).to be_frozen
    end
  end

  describe '#clear' do
    context 'when the absent tree has not been created' do
      it 'does nothing' do
        expect { absent_tree.clear }.not_to change { absent_tree }
      end

      it 'does return the absent tree' do
        expect( absent_tree.clear ).to be absent_tree
      end
    end

    context 'when the absent tree has been created' do
      before(:each) { absent_tree.add :something }

      it 'does delegate to the created tree' do
        expect(absent_tree.presence).to receive(:clear)
        absent_tree.clear
      end
    end
  end

  describe '#delete' do
    context 'when the absent tree has not been created' do
      it 'does nothing' do
        expect { absent_tree.delete 42 }.not_to change { absent_tree }
      end

      it 'does return the absent tree' do
        expect( absent_tree.delete 42 ).to be absent_tree
      end
    end

    context 'when the absent tree has been created' do
      before(:each) { absent_tree.add :something }

      it 'does delegate to the created tree' do
        expect(absent_tree.presence).to receive(:delete)
        absent_tree.delete 42
      end
    end
  end


  ############################################################################
  # query methods
  ############################################################################

  let(:nothing) { spy('nothing') }

  UNSUPPORTED_TEST_DOUBLE_METHODS = %i[hash to_s]
  EXCLUDE_QUERY_METHODS = %i[== === eql? dup clone] + UNSUPPORTED_TEST_DOUBLE_METHODS +
    Sycamore::Absence.instance_methods(false)

  (Sycamore::Tree.query_methods - EXCLUDE_QUERY_METHODS).each do |query_method|

    describe "##{query_method}" do
      context 'when the absent tree has not been created' do
        it 'does delegate to Nothing' do
          absent_tree.instance_variable_set(:@tree, nothing)
          absent_tree.send(query_method)
          expect(nothing).to have_received(query_method)
        end

        # it 'does not create the absent tree' do
        #   absent_tree.send(query_method)
        #   expect( absent_tree ).to be_absent
        # end
      end

      context 'when the absent tree has been created' do
        before(:each) { absent_tree.add :something }

        let(:created_tree) { absent_tree.presence }

        it 'does delegate to the created tree' do
          expect(created_tree).to be_present
          expect(created_tree).to receive(query_method)
          absent_tree.send(query_method)
        end
      end
    end

  end

  describe '#dup' do
    context 'when the absent tree has not been created' do
      it 'does raise an error' do
        expect { absent_tree.dup }.to raise_error TypeError
      end
    end

    context 'when the absent tree has been created' do
      before(:each) { absent_tree.add :something }
      let(:created_tree) { absent_tree.presence }

      it 'does return a duplicate of the present tree, not the Absence' do
        duplicate = absent_tree.dup
        expect(duplicate).not_to be_a Sycamore::Absence
        expect(duplicate).to be_a Sycamore::Tree
      end

      it 'does delegate to the created tree' do
        expect(created_tree).to be_present
        expect(created_tree).to receive(:dup)
        absent_tree.dup
      end
    end
  end

  describe '#clone' do
    context 'when the absent tree has not been created' do
      it 'does raise an error' do
        expect { absent_tree.clone }.to raise_error TypeError
      end
    end

    context 'when the absent tree has been created' do
      before(:each) { absent_tree.add :something }
      let(:created_tree) { absent_tree.presence }

      it 'does return a duplicate of the present tree, not the Absence' do
        klone = absent_tree.clone
        expect(klone).not_to be_a Sycamore::Absence
        expect(klone).to be_a Sycamore::Tree
      end

      it 'does delegate to the created tree' do
        expect(created_tree).to be_present
        expect(created_tree).to receive(:clone)
        absent_tree.clone
      end
    end
  end

  describe '#frozen?' do
    context 'when the absent tree has not been created' do
      pending
    end

    context 'when the absent tree has been created' do
      before(:each) { absent_tree.add :something }

      it 'does delegate to the created tree'
    end
  end


  describe '#child_of' do

    context 'when the absent tree has not been created' do
      it 'does return another absent tree' do
        expect( absent_tree.child_of(:another) )
          .to be_a(Sycamore::Absence)
          .and be_absent
          .and be_different_to absent_tree
      end

      context 'edge cases' do
        it 'does raise an error, when given nil' do
          expect { absent_tree.child_of(nil) }.to raise_error Sycamore::InvalidNode
        end

        it 'does raise an error, when given the Nothing tree' do
          expect { absent_tree.child_of(Sycamore::Nothing) }.to raise_error Sycamore::InvalidNode
        end

        it 'does raise an error, when given an Enumerable' do
          expect { absent_tree.child_of([1]) }.to raise_error Sycamore::InvalidNode
          expect { absent_tree.child_of([1, 2]) }.to raise_error Sycamore::InvalidNode
          expect { absent_tree.child_of(foo: :bar) }.to raise_error Sycamore::InvalidNode
          expect { absent_tree.child_of(Sycamore::Tree[1]) }.to raise_error Sycamore::InvalidNode
        end
      end
    end

    context 'when the absent tree has been created' do
      before(:each) { absent_tree.add :something }
      let(:created_tree) { absent_tree.presence }

      it 'does delegate to the created tree' do
        expect(created_tree).to receive(:child_of)
        absent_tree.child_of(:something)
      end
    end
  end

  describe '#child_at' do

    context 'when the absent tree has not been created' do
      it 'does return another absent tree' do
        expect( absent_tree[1,2,3] )
          .to be_a(Sycamore::Absence)
          .and be_absent
          .and be_different_to absent_tree
      end
    end

    context 'when the absent tree has been created' do
      before(:each) { absent_tree.add :something }
      let(:created_tree) { absent_tree.presence }

      it 'does delegate to the created tree' do
        expect(created_tree).to receive(:child_at)
        absent_tree.child_at(:something)
      end
    end
  end

  ############################################################################
  # Conversion
  ############################################################################

  describe '#to_s' do
    context 'when the absent tree has not been created' do
      it 'does delegate to Nothing' do
        expect( absent_tree.to_s ).to eql Sycamore::Nothing.to_s
      end
    end

    context 'when the absent tree has been created' do
      before(:each) { absent_tree.add :something }

      it 'does delegate to the created tree' do
        expect( absent_tree.to_s ).to eql Sycamore::Tree[:something].to_s
      end
    end
  end

  describe '#inspect' do
    shared_examples_for 'every inspect string' do |absent_tree|
      context 'when the absent tree has not been created' do
        it 'contains the word "absent"' do
          expect( absent_tree.inspect ).to include 'absent child tree of'
        end
      end

      context 'when the absent tree has been created' do
        before(:each) { absent_tree.add :something }

        it 'contains the word "present"' do
          expect( absent_tree.inspect ).to include 'present child tree of'
        end
      end

      it 'contains the inspect representation of the parent tree' do
        expect( absent_tree.inspect ).to include absent_tree.instance_variable_get(:@parent_tree).inspect
      end

      it 'contains the inspect representation of the parent node' do
        expect( absent_tree.inspect ).to include absent_tree.instance_variable_get(:@parent_node).inspect
      end
    end

    include_examples 'every inspect string', Sycamore::Absence.new(Sycamore::Tree.new, :missing)
    include_examples 'every inspect string', Sycamore::Absence.new(Sycamore::Tree[1,2,3], :missing)
  end


  ############################################################################
  # Equality
  ############################################################################

  describe '#===' do
    context 'when the absent tree has not been created' do
      it 'does delegate to Nothing' do
        expect( absent_tree === Sycamore::Nothing ).to be true
        expect( Sycamore::Nothing === absent_tree ).to be true
      end
    end

    context 'when the absent tree has been created' do
      before(:each) { absent_tree.add :something }

      it 'does delegate to the created tree' do
        expect( absent_tree === Sycamore::Tree[:something] ).to be true
        expect( Sycamore::Tree[:something] === absent_tree ).to be true
      end
    end
  end

  describe '#==' do
    context 'when the absent tree has not been created' do
      it 'does delegate to Nothing' do
        expect( absent_tree == Sycamore::Nothing ).to be true
        expect( Sycamore::Nothing == absent_tree ).to be true
      end
    end

    context 'when the absent tree has been created' do
      before(:each) { absent_tree.add :something }

      it 'does delegate to the created tree' do
        expect( absent_tree == Sycamore::Tree[:something] ).to be true
        expect( Sycamore::Tree[:something] == absent_tree ).to be true
      end
    end
  end

  describe '#eql?' do
    context 'when the absent tree has not been created' do
      it 'does delegate to Nothing' do
        expect( absent_tree.eql? Sycamore::Nothing ).to be true
        expect( Sycamore::Nothing.eql? absent_tree ).to be true
      end
    end

    context 'when the absent tree has been created' do
      before(:each) { absent_tree.add :something }

      it 'does delegate to the created tree' do
        expect( absent_tree.eql? Sycamore::Tree[:something] ).to be true
        expect( Sycamore::Tree[:something].eql? absent_tree ).to be true
      end
    end
  end

  describe '#hash' do
    context 'when the absent tree has not been created' do
      it 'does delegate to Nothing' do
        expect( absent_tree.hash ).to be Sycamore::Nothing.hash
      end
    end

    context 'when the absent tree has been created' do
      before(:each) { absent_tree.add :something }

      it 'does delegate to the created tree' do
        expect( absent_tree.hash ).to be Sycamore::Tree[:something].hash
      end
    end
  end

end
