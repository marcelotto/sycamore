describe Sycamore::Absence do

  subject(:example_absence) { Sycamore::Absence.at(parent_tree, parent_node) }

  let(:some_absence) { Sycamore::Absence.new(Sycamore::Tree.new, :missing) }

  describe '#initialize' do
    it 'does raise an error, if not given a parent tree and node' do
      expect { Sycamore::Absence.new(nil, nil) }.to raise_error ArgumentError
      expect { Sycamore::Absence.new(1, nil) }.to raise_error ArgumentError
      expect { Sycamore::Absence.new(1, 1) }.to raise_error ArgumentError
      expect { Sycamore::Absence.new(Sycamore::Tree[], nil) }.to raise_error ArgumentError
    end
  end

  describe '#nothing?' do
    specify { expect( some_absence.nothing? ).to be false }
  end

  describe '#absent?' do
    specify { expect( some_absence.absent? ).to be true }

    context 'when the absent tree was created and installed' do
      context 'when it is blank' do
        before(:each) { some_absence.add nil }
        specify { expect( some_absence.absent? ).to be false }
      end
      context 'when it is not blank' do
        before(:each) { some_absence.add :foo }
        specify { expect( some_absence.absent? ).to be false }
      end
    end
  end

  describe '#present?' do
    specify { expect( some_absence.present? ).to be false }

    context 'when the absent tree was created and installed' do
      context 'when it is blank' do
        before(:each) { some_absence.add nil }
        specify { expect( some_absence.present? ).to be false }
      end
      context 'when it is not blank' do
        before(:each) { some_absence.add :foo }
        specify { expect( some_absence.present? ).to be true }
      end
    end
  end

  describe '#child_of' do
    context 'edge cases' do
      it 'does raise an IndexError, when given nil' do
        expect { some_absence.child_of(nil) }.to raise_error IndexError
      end
    end
  end


  shared_examples_for 'all Tree method calls on an absence' do

    context 'when requested' do

      describe 'query methods' do
        it { is_expected.to     be_requested }
        it { is_expected.not_to be_created }
        it { is_expected.not_to be_installed }
        it { is_expected.not_to be_present }
        it { is_expected.to     be_absent }
        it { is_expected.not_to be_nothing }
        it { is_expected.not_to be_absent_parent }
        it { is_expected.to     be_empty }

        it { is_expected.to be_leaves }
        specify { expect( example_absence.leaf?(42) ).to be false }
        specify { pending 'Should the general behaviour of leaves? for empty nodes be to return true?'
                  expect( Sycamore::Absence.new.leaves? ).to be false }
        specify { expect( example_absence.leaves?(1,2,3) ).to be false }

        specify { expect( example_absence.include?(42) ).to be false }

        specify { expect( example_absence.size    ).to be 0 }
        specify { expect( example_absence.nodes   ).to eq [] }
        specify { expect( example_absence.to_a    ).to eq [] }
        specify { expect( example_absence.to_h    ).to eq({}) }
        specify { expect( example_absence.to_s    ).to eq Sycamore::Tree[].to_s }
        specify { expect( example_absence.inspect ).to eq "Sycamore::Absence.at(#{parent_tree}, #{parent_node})" }

        describe '#child_of' do
          subject { example_absence.child_of(:of_absent_node) }

          it { is_expected.to be_a Sycamore::Absence }
          it { is_expected.not_to be example_absence }
          it { is_expected.to be_requested }
          it { is_expected.not_to be_installed }
          it { is_expected.to be_absent_parent }
        end
      end

      describe 'non-creating command methods' do
        specify { expect( example_absence.clear ).to be example_absence }
        specify { pending 'Tree#remove' ; expect( example_absence.remove 42 ).to be example_absence }
      end

    end

    context 'when created' do

      shared_examples_for 'the created tree' do |added_data|
        it { is_expected.not_to be_absent }
        it { is_expected.to     be_present }
        it { is_expected.not_to be_nothing }

        it 'is empty when given Nothing or nil, otherwise not' do
          if added_data == Sycamore::Nothing or added_data.nil?
            is_expected.to be_empty
          else
            is_expected.not_to be_empty
          end
        end

        it { is_expected.to include added_data }
      end

      shared_examples_for 'creating a tree by adding' do |input|
        context "creating a tree by adding #{input}" do
          let(:data)             { input }
          let(:example_presence) { example_absence << data }

          subject        { example_presence }
          before(:each)  { example_presence }


          describe 'the created tree' do
            it { is_expected.not_to be example_absence }
            it { is_expected.not_to be_a Sycamore::Absence }

            include_examples 'the created tree', input
          end

          describe 'the absence object' do
            subject { example_absence }

            specify { expect( example_absence.presence ).to be example_presence }

            it_behaves_like 'the created tree', input

            it { is_expected.not_to be_requested }
            it { is_expected.to     be_created }
            it { is_expected.to     be_installed }
            it { is_expected.not_to be_absent_parent }
          end

          describe 'the parent tree' do
            subject { parent_tree }
            it { is_expected.to include parent_node }
            it { is_expected.to include parent_node => data }
          end
        end
      end

      # TODO spec the negation of: include_examples 'creating a tree by adding', nil
      # TODO: include_examples 'creating a tree by adding', Sycamore::Nothing
      include_examples 'creating a tree by adding', number
      include_examples 'creating a tree by adding', [symbol, number, string]
      include_examples 'creating a tree by adding', {symbol => number, symbol => string}

      # TODO: include_examples 'creating a tree by adding', nil ???
      # TODO: include_examples 'creating a tree by adding', Nothing ???


      shared_examples_for 'creating a tree by adding to a child of an absence' do |first, second|
        context "creating a tree by adding #{second} to a child of an absent #{first}" do
          let(:input1)                  { first }
          let(:input2)                  { second }
          let(:tree)                    { { input1 => input2 } }

          let(:example_parent_absence)  { example_absence }
          let(:example_child_absence)   { example_parent_absence[input1] }
          let(:example_child_presence)  { example_child_absence << input2 }
          let(:example_parent_presence) { example_parent_absence.presence }

          subject        { example_child_presence }
          before(:each)  { example_child_presence }

          describe 'the created child tree' do
            it { is_expected.not_to be example_child_absence }
            it { is_expected.not_to be example_parent_absence }
            it { is_expected.not_to be example_parent_presence }
            it { is_expected.not_to be_a Sycamore::Absence }
            include_examples 'the created tree', second

            describe 'the created parent tree' do
              subject { example_parent_presence }
              it { is_expected.not_to be example_child_presence }
              it { is_expected.not_to be example_child_absence }
              it { is_expected.not_to be example_parent_absence }
              it { is_expected.not_to be_a Sycamore::Absence }
              include_examples 'the created tree', first
            end
          end

          describe 'the child absence object' do
            subject { example_child_absence }
            specify { expect( example_child_absence.presence ).to be example_child_presence }

            it { is_expected.not_to be_requested }
            it { is_expected.to     be_created }
            it { is_expected.to     be_installed }
            it { is_expected.not_to be_absent_parent }

            it_behaves_like 'the created tree', second

            describe 'the absent parent tree' do
              subject { example_parent_absence }

              it { is_expected.not_to be_requested }
              it { is_expected.to     be_created }
              it { is_expected.to     be_installed }
              it { is_expected.not_to be_absent_parent }

              it_behaves_like 'the created tree', first

              describe 'its parent tree' do
                subject { example_parent_absence.instance_variable_get :@parent_tree }
                it { is_expected.to be parent_tree }
              end
            end
          end

        end
      end

      include_examples 'creating a tree by adding to a child of an absence', symbol, number
      include_examples 'creating a tree by adding to a child of an absence', string, [symbol, number, string]
      include_examples 'creating a tree by adding to a child of an absence', number, {symbol => number, symbol => string}
    end

    context 'when negated' do

    end

  end


  context 'when the child tree is already present' do
    let(:parent_node) { symbol }
    let(:parent_tree) { Sycamore::Tree[parent_node => 'existing child'] }

    pending 'Should this fail?'
    # because there is really something wrong, when an Absence refers to
    # something existing, which it didn't create ...?
  end

  context 'when the node is present, but the child tree absent' do
    let(:parent_node) { symbol }
    let(:parent_tree) { Sycamore::Tree[parent_node] }

    include_examples 'all Tree method calls on an absence'

    context 'when requested' do
    end

    context 'when created' do
    end

    context 'when negated' do
    end

  end

  context 'when the node and child tree are absent' do
    let(:parent_node) { symbol }
    let(:parent_tree) { Sycamore::Tree[] }

    include_examples 'all Tree method calls on an absence'

    context 'when requested' do
    end

    context 'when created' do
    end

    context 'when negated' do
    end

  end

end
