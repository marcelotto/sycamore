# all specs for interactions between Tree and Absence units!

describe Sycamore::Tree do
  describe '#child' do
    context 'when given a single atom' do
      context 'when a corresponding node is absent' do

        let(:root) { Sycamore::Tree() }
        let(:absent_child) { root[:absent_node_child] }

        describe 'root' do
          subject { root }
          it { is_expected.to be_empty }
        end

        describe 'absent child' do
          subject { absent_child }
          it { is_expected.to     be_a Sycamore::Absence }
          # it { is_expected.to     be_a Sycamore::Tree }
          # it { is_expected.to     be   Sycamore::Nothing }
          it { is_expected.not_to be_nothing }
          it { is_expected.not_to be_present }
          it { is_expected.to     be_absent }
          it { is_expected.to     be_requested } # TODO: Remove these, since private!?
          it { is_expected.not_to be_created }   # TODO: Remove these, since private!?
          it { is_expected.not_to be_installed } # TODO: Remove these, since private!?
          it { is_expected.not_to be_absent_parent } # TODO: Remove these, since private!?
          it { is_expected.to     be_empty }
          it { is_expected.not_to include :absent_node_child } # This relies on Tree#each
          specify { expect( absent_child.include?(:absent_node_child) ).to be false }
        end

        context 'when something gets added to the absent child' do
          let(:more)    { :more }
          before(:each) { absent_child.add more }

          describe 'root' do
            subject { root }
            it { is_expected.to include :absent_node_child }
            it { expect( root.include?(:absent_node_child) ).to be true }
          end

          describe 'the obsolete absent child object' do
            subject { absent_child }
            it { is_expected.to be_a Sycamore::Absence }
            # it { is_expected.to     be_a Sycamore::Tree }
            # it { is_expected.to     be   Sycamore::Nothing }
            it { is_expected.not_to be_nothing }
            it { is_expected.not_to be_absent }
            it { is_expected.to     be_present }
            it { is_expected.not_to be_requested }
            it { is_expected.to     be_created }
            it { is_expected.to     be_installed }
            it { is_expected.not_to be_empty }
            it { is_expected.to include more } # This relies on Tree#each
            specify { expect( absent_child.include?(more) ).to be true }
          end

          describe 'the constructed child' do
            subject(:new_child) { root[:absent_node_child] }
            it { is_expected.not_to be_a Sycamore::Absence }
            it { is_expected.not_to be   Sycamore::Nothing }
            it { is_expected.to     be_a Sycamore::Tree }
            it { is_expected.not_to be_nothing }
            it { is_expected.not_to be_absent }
            it { is_expected.to     be_present }
            it { is_expected.not_to be_empty }
            it { is_expected.to include more } # This relies on Tree#each
            specify { expect( new_child.include?(more) ).to be true }
          end

        end

      end

    end
  end

  describe '#fetch' do
    # Tree#fetch explicitly does NOT involve Absence, so their is no interaction
  end

  describe '#delete' do

    context 'when given Absence' do
      pending
    end

  end
end
