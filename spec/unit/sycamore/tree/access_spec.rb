describe Sycamore::Tree do

  describe '#child' do

    context 'when given a single argument' do

      context 'edge cases' do
        context 'when the argument is nil' do
          specify { expect( Tree.new.child_of(nil) ).to be Sycamore::Nothing }
        end

        context 'when the argument is Nothing' do
          specify { expect(Tree.new.child_of(Sycamore::Nothing)).to be Sycamore::Nothing }
        end

        context 'when the argument is false' do
          specify { expect( Tree.new.child_of(false) ).to be_a Sycamore::Absence }
          specify { expect( Tree.new.child_of(false) ).not_to be_nothing }
          specify { expect( Tree.new.child_of(false) ).to be_absent }

          specify { expect( Tree[false => :foo].child_of(false) ).not_to be Sycamore::Nothing }
          specify { expect( Tree[false => :foo].child_of(false) ).not_to be_absent }
          specify { expect( Tree[false => :foo].child_of(false) ).to include :foo }

          specify { expect( Tree[4 => {false => 2}].child_of(4) ).to eq Tree[false => 2] }
          specify { expect( Tree[4 => {false => 2}].child_of(4).child_of(false) ).not_to be_a Sycamore::Absence }
          specify { expect( Tree[4 => {false => 2}].child_of(4).child_of(false) ).to eq Tree[2] }
        end
      end

      context 'when a corresponding node is present' do

        context 'when the node has a child' do
          let(:root) { Sycamore::Tree.new.add_child(:property, :value) }
          let(:child) { root[:property] }

          describe 'root' do
            subject { root }
            it { is_expected.to include :property }
            it { is_expected.not_to include :value } # This relies on Tree#each
            it { expect( root.include?(:value) ).to be false }
          end

          describe 'child' do
            subject { child }
            it { is_expected.to be_a Sycamore::Tree }
            it { is_expected.not_to be Sycamore::Nothing }
            it { is_expected.not_to be_nothing }
            it { is_expected.not_to be_absent }
            it { is_expected.to include :value }
            it { is_expected.not_to include :property } # This relies on Tree#each
            it { expect( child.include?(:property) ).to be false }
          end
        end

        context 'when the node is a leaf' do
          let(:root) { Sycamore::Tree[42] }
          let(:child) { root.child_of(42) }

          # TODO: Really the same behaviour as when node absent?

          describe 'root' do
            subject { root }
            it { is_expected.to include 42 }
          end

          describe 'child' do
            subject { child }
            it { is_expected.to be_a Sycamore::Absence }
            it { is_expected.to be_absent }
            # it { is_expected.to be_a Sycamore::Tree }
            # it { is_expected.to be Sycamore::Nothing }
          end

        end
      end

      context 'when a corresponding node is absent' do

        # see Tree-Absence interaction spec

        # TODO: Really the same behaviour as when node is a leaf?
      end

    end

  end

  ############################################################################

  describe '#fetch' do

    context 'when given a single atom' do

      context 'when the given atom is nil' do
        specify { expect { Sycamore::Tree[].fetch(nil) }.to raise_error KeyError }
      end

      context 'when the given atom is Nothing' do
        specify { expect { Sycamore::Tree[].fetch(Nothing) }.to raise_error KeyError }
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
        specify { expect( Sycamore::Tree[].fetch(Nothing, :default) ).to eq :default }
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
        specify { expect( Sycamore::Tree[].fetch(Nothing) { 42 } ).to eq 42 }
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
        specify { expect( Sycamore::Tree[].fetch(Nothing, :default) { 42 } ).to eq 42 }
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
