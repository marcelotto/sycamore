describe Sycamore::Tree do

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

  describe '#child_of' do

    it 'does return the child tree of the given node, when given the node is present' do
      expect( Sycamore::Tree[property: :value].child_of(:property).node ).to be :value
      expect( Sycamore::Tree[false => 42     ].child_of(false).node     ).to be 42
      expect( Sycamore::Tree[4 => {false=>2} ].child_of(4) ).to eq Sycamore::Tree[false=>2]
    end

    it 'does return an absent tree, when the given node is a leaf' do
      expect( Sycamore::Tree[42   ].child_of(42   ) ).to be_a Sycamore::Absence
      expect( Sycamore::Tree[false].child_of(false) ).to be_a Sycamore::Absence
    end

    it 'does return an absent tree, when given the node is not present' do
      expect( Sycamore::Tree.new.child_of(:missing) ).to be_a Sycamore::Absence
      expect( Sycamore::Tree.new.child_of(false   ) ).to be_a Sycamore::Absence
    end

    context 'edge cases' do
      it 'does raise an IndexError, when given nil' do
        expect { Sycamore::Tree.new.child_of(nil) }.to raise_error IndexError
      end
    end

  end


  ############################################################################

  describe '#child_at' do

    it 'does return the child tree of the given node, when the node at the given path is present' do
      expect( Sycamore::Tree[property: :value].child_at(:property).node ).to be :value
      expect( Sycamore::Tree[false => 42     ].child_at(false).node     ).to be 42
      expect( Sycamore::Tree[4 => {false=>2} ].child_at(4) ).to eq Sycamore::Tree[false=>2]

      expect( Sycamore::Tree[1 => {2 => 3}].child_at(1, 2).node ).to be 3
      expect( Sycamore::Tree[1 => {2 => 3}].child_at([1, 2]).node ).to be 3
    end

    it 'does return an absent tree, when the node at the given path is a leaf' do
      expect( Sycamore::Tree[42   ].child_at(42     )   ).to be_a Sycamore::Absence
      expect( Sycamore::Tree[1,2,3].child_at(1, 2, 3)   ).to be_a Sycamore::Absence
      expect( Sycamore::Tree[1,2,3].child_at([1, 2, 3]) ).to be_a Sycamore::Absence
    end

    context 'when the node at the given path is not present' do
      it 'does return an absent tree' do
        expect( Sycamore::Tree.new.child_at(:missing ) ).to be_a Sycamore::Absence
        expect( Sycamore::Tree.new.child_at( 1, 2, 3 ) ).to be_a Sycamore::Absence
        expect( Sycamore::Tree.new.child_at([1, 2, 3]) ).to be_a Sycamore::Absence
      end

      it 'does return a correctly configured absent tree' do
        tree = Sycamore::Tree.new
        absent_tree = tree.child_at(1, 2, 3)
        absent_tree << []
        expect(tree).to eq Sycamore::Tree[1=>{2=>3}]
      end
    end

    context 'edge cases' do
      it 'does raise an ArgumentError, when given no arguments' do
        expect { Sycamore::Tree.new.child_at() }.to raise_error ArgumentError
      end

      it 'does raise an IndexError, when the given path contains nil' do
        expect { Sycamore::Tree.new.child_at(nil, nil) }.to raise_error IndexError
        expect { Sycamore::Tree.new.child_at(1, nil  ) }.to raise_error IndexError
        expect { Sycamore::Tree.new.child_at(nil, 1  ) }.to raise_error IndexError
      end
    end

  end

  ############################################################################

  # TODO: Clean this up!
  describe '#fetch' do

    context 'when given a single atom' do

      context 'when the given atom is nil' do
        specify { expect { Sycamore::Tree[].fetch(nil) }.to raise_error KeyError }
      end

      context 'when the given atom is Nothing' do
        specify { expect { Sycamore::Tree[].fetch(Sycamore::Nothing) }.to raise_error KeyError }
      end

      context 'when the given atom is a boolean' do
        specify { expect { Sycamore::Tree[].fetch(true) }.to raise_error KeyError }
        specify { expect { Sycamore::Tree[].fetch(false) }.to raise_error KeyError }
        specify { expect( Sycamore::Tree[true].fetch(true) ).to be Sycamore::Nothing }
        specify { expect( Sycamore::Tree[false].fetch(false) ).to be Sycamore::Nothing }
      end

      context 'when a corresponding node is present' do
        subject(:tree) { Sycamore::Tree[property: :value] }
        specify { expect( tree.fetch(:property) ).to be tree.child_of(:property) }

        context 'when the node is a leaf' do
          specify { expect( Sycamore::Tree[42].fetch(42) ).to be Sycamore::Nothing }
        end
      end

      context 'when a corresponding node is absent' do
        specify { expect { Sycamore::Tree[].fetch(42) }.to raise_error KeyError }
      end

    end

    context 'when given an atom and a default value' do

      context 'when the given atom is nil' do
        specify { expect( Sycamore::Tree[].fetch(nil, :default) ).to eq :default }
      end

      context 'when the given atom is Nothing' do
        specify { expect( Sycamore::Tree[].fetch(Sycamore::Nothing, :default) ).to eq :default }
      end

      context 'when the given atom is a boolean' do
        specify { expect( Sycamore::Tree[     ].fetch(true,  :default) ).to eq :default }
        specify { expect( Sycamore::Tree[     ].fetch(false, :default) ).to eq :default }
        specify { expect( Sycamore::Tree[true ].fetch(true,  :default) ).to be Sycamore::Nothing }
        specify { expect( Sycamore::Tree[false].fetch(false, :default) ).to be Sycamore::Nothing }
      end

      context 'when a corresponding node is present' do
        subject(:tree) { Sycamore::Tree[property: :value] }
        specify { expect( tree.fetch(:property, :default) ).to be tree.child_of(:property) }

        context 'when the node is a leaf' do
          specify { expect( Sycamore::Tree[:property].fetch(:property, :default) ).to be Sycamore::Nothing }
        end
      end

      context 'when a corresponding node is absent' do
        specify { expect( Sycamore::Tree[].fetch(42, "default") ).to eq "default" }
      end

    end

    context 'when given an atom and a block' do

      context 'when the given atom is nil' do
        specify { expect( Sycamore::Tree[].fetch(nil) { 42 } ).to eq 42 }

      end

      context 'when the given atom is Nothing' do
        specify { expect( Sycamore::Tree[].fetch(Sycamore::Nothing) { 42 } ).to eq 42 }
      end

      context 'when the given atom is a boolean' do
        specify { expect( Sycamore::Tree[     ].fetch(true ) { 42 } ).to eq 42 }
        specify { expect( Sycamore::Tree[     ].fetch(false) { 42 } ).to eq 42 }
        specify { expect( Sycamore::Tree[true ].fetch(true)  { 42 } ).to be Sycamore::Nothing }
        specify { expect( Sycamore::Tree[false].fetch(false) { 42 } ).to be Sycamore::Nothing }
      end

      context 'when a corresponding node is present' do
        subject(:tree) { Sycamore::Tree[property: :value] }
        specify { expect( tree.fetch(:property) { 42 } ).to be tree.child_of(:property) }

        context 'when the node is a leaf' do
          specify { expect( Sycamore::Tree[:property].fetch(:property) { 42 } ).to be Sycamore::Nothing }
        end
      end

      context 'when a corresponding node is absent' do
        specify { expect( Sycamore::Tree[].fetch(:property) { 42 } ).to eq 42 }
      end

    end

    context 'when given an atom, a default value and a block' do

      context 'when the given atom is nil' do
        specify { expect( Sycamore::Tree[].fetch(nil, :default) { 42 } ).to eq 42 }

      end

      context 'when the given atom is Nothing' do
        specify { expect( Sycamore::Tree[].fetch(Sycamore::Nothing, :default) { 42 } ).to eq 42 }
      end

      context 'when the given atom is a boolean' do
        specify { expect( Sycamore::Tree[     ].fetch(true,  :default) { 42 } ).to eq 42 }
        specify { expect( Sycamore::Tree[     ].fetch(false, :default) { 42 } ).to eq 42 }
        specify { expect( Sycamore::Tree[true ].fetch(true,  :default) { 42 } ).to be Sycamore::Nothing }
        specify { expect( Sycamore::Tree[false].fetch(false, :default) { 42 } ).to be Sycamore::Nothing }
      end

      context 'when a corresponding node is present' do
        subject(:tree) { Sycamore::Tree[property: :value] }
        specify { expect( tree.fetch(:property, :default) { 42 } ).to be tree.child_of(:property) }

        context 'when the node is a leaf' do
          specify { expect( Sycamore::Tree[:property].fetch(:property, :default) { 42 } ).to be Sycamore::Nothing }
        end
      end

      context 'when a corresponding node is absent' do
        specify { expect( Sycamore::Tree[].fetch(:property) { 42 } ).to eq 42 }
      end

    end

  end

end
