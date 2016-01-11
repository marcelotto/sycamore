describe Sycamore::Tree do


  describe '#delete' do
    context 'when given nil' do
      let(:nodes) { [:foo] }
      subject(:tree) { Sycamore::Tree[nodes].delete(nil) }

      it { is_expected.to include nodes }
      it { expect(tree.size).to be 1 }
    end

    context 'when given Nothing' do
      let(:nodes) { [42, :foo] }
      subject(:tree) { Sycamore::Tree[nodes].delete(Sycamore::Nothing) }

      it { is_expected.to include nodes }
      it { expect(tree.size).to be 2 }
    end

    context 'when given Absence' do
      pending
    end

    context 'when given a single atom' do
      context 'when the given node is in this tree' do
        let(:nodes) { [42, :foo] }
        subject(:tree) { Sycamore::Tree[nodes].delete(42) }

        it { is_expected.not_to include 42 } # This relies on Tree#each
        it { expect(tree.include?(42)).to be false }
        it { is_expected.to include :foo }

        it 'does decrease the size' do
          expect(tree.size).to be nodes.size - 1
        end
      end

      context 'when the given node is not in this tree' do
        let(:initial_nodes) { [:foo] }
        subject(:tree) { Sycamore::Tree[initial_nodes].delete(42) }

        it { expect(tree.include? 42).to be false }
        it { is_expected.not_to include 42 } # This relies on Tree#each
        it { expect(tree.include? :foo).to be true }
        it { is_expected.to include :foo }

        it 'does not decrease the size' do
          expect(tree.size).to be initial_nodes.size
        end
      end
    end

    context 'when given a collection of atoms' do
      context 'when all of the given node are in this tree' do
        let(:initial_nodes)       { [:foo, :bar] }
        let(:nodes_to_be_deleted) { [:foo, :bar] }

        subject(:tree) { Sycamore::Tree[initial_nodes].delete(nodes_to_be_deleted) }

        it 'does not include any of the deleted nodes' do
          nodes_to_be_deleted.each { |node| is_expected.not_to include node }
        end

        it 'does decrease the size' do
          expect(tree.size).to be initial_nodes.size - nodes_to_be_deleted.size
        end
      end

      context 'when some, but not all of the given node are in this tree' do
        let(:initial_nodes)       { [42, :foo] }
        let(:nodes_to_be_deleted) { [:foo, :bar] }

        subject(:tree) { Sycamore::Tree[initial_nodes].delete(nodes_to_be_deleted) }

        it { expect(tree.include? 42).to be true }
        it { is_expected.to include 42 } # This relies on Tree#each
        it { expect(tree.include? :foo).to be false }
        it { is_expected.not_to include :foo }

        it 'does not decrease the size' do
          expect(tree.size).to be 1
        end
      end

      context 'when none of the given node are in this tree' do
        let(:initial_nodes)       { [1, 2] }
        let(:nodes_to_be_deleted) { [:foo, :bar] }

        subject(:tree) { Sycamore::Tree[initial_nodes].delete(nodes_to_be_deleted) }

        it 'does not decrease the size' do
          expect(tree.size).to be initial_nodes.size
        end
      end

      context 'when given a nested Enumerable' do
        context 'when the nested Enumerable is Tree-like' do
          specify { expect(Sycamore::Tree[a: 1, b: 2].delete([:a, b: 2]) ).to be_empty }
          specify { expect(Sycamore::Tree[a: 1, b: [2, 3]].delete([:a, b: 2]) === {b: 3} ).to be true }
        end

        context 'when the nested Enumerable is not Tree-like' do
          # @todo https://www.pivotaltracker.com/story/show/94733228
          #   Do we really need this? If so, document the reasons!
          it 'raises an error' do
            expect { Sycamore::Tree.new.delete([1, [2, 3]]) }.to raise_error(Sycamore::NestedNodeSet)
          end
        end

      end

    end

  end

  ############################################################################

  describe '#delete_children' do

    context 'when Nothing given' do
      subject { Tree[].delete_children(Sycamore::Nothing) }
      it      { is_expected.to be_empty }
    end

    context 'when Absence given' do
      subject { Tree[42].delete_children(Tree[].child_of(42)) }
      it      { is_expected.to include 42 }
    end

    context 'when given the empty hash' do
      subject { Tree[].delete_children({}) }
      it      { is_expected.to be_empty }
    end

    specify { expect(Tree[a: 1].delete(a: 1)).to be_empty }
    specify { expect(Tree[a: [1, 2]].delete(:a)).to be_empty }
    specify { expect(Tree[a: [1, 2]].delete(a: 2)).to include(a: 1) }
    specify { expect(Tree[a: [1, 2]].delete(a: 2)).not_to include(a: 2) }

    specify { expect(Tree[a: 1, b: 2].delete(:a)).to include(b: 2) }
    specify { expect(Tree[a: 1, b: 2].delete(:a)).not_to include(a: 1) }

    specify { expect(Tree[a: 1, b: [2, 3]].delete(a: 1, b: 2) === {b: 3}).to be true }

  end

  ############################################################################

  describe '#clear' do

    context 'when empty' do
      subject(:empty_tree) { Sycamore::Tree[] }
      specify { expect { empty_tree.clear }.not_to change(empty_tree, :size) }
      specify { expect { empty_tree.clear }.not_to change(empty_tree, :nodes) }
    end

    context 'when not empty' do
      let(:nodes) { [42, :foo] }
      subject { Sycamore::Tree[nodes].clear }

      it { is_expected.to be_empty }

      it 'does delete all nodes' do
        nodes.each do |node|
          expect(subject.include?(node)).to be false
          expect(subject).not_to include(node) # This relies on Tree#each
        end
      end
    end

  end

end
