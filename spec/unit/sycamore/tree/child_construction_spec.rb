describe Sycamore::Tree do

  let(:tree) { Sycamore::Tree.new }

  ############################################################################

  describe 'child constructor integration' do
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

  ############################################################################

  describe '#new_child' do
    let(:subclass) { Class.new(Sycamore::Tree) }

    subject { tree.new_child }

    context 'when no child constructor defined' do

      it { is_expected.to eql Sycamore::Tree.new }

      context 'on a subclass' do
        let(:tree) { subclass.new }
        it { is_expected.to eql subclass.new }
      end
    end

    context 'when a child constructor defined' do

      context 'when the child constructor is a Tree class' do
        let(:tree_class) { Class.new(Sycamore::Tree) }

        before(:each) { tree.child_constructor = tree_class }

        it { is_expected.to eql tree_class.new }

        context 'on a subclass' do
          let(:tree) { subclass.new }
          it { is_expected.to eql tree_class.new }
        end

      end

      context 'when a child prototype Tree instance defined' do
        pending 'Tree#clone'
      end

      context 'when a child constructor Proc defined' do

        before(:each) do
          tree.def_child_generator { Sycamore::Tree[42] }
        end

        it { is_expected.to be === Sycamore::Tree[42] }

        context 'on a subclass' do
          let(:tree) { subclass.new }
          it { is_expected.to be === subclass[42] }
        end

      end

    end

  end

  ############################################################################

  describe '#child_constructor' do

    specify { expect { tree.child_constructor = 'foo' }.to raise_error ArgumentError }

    context 'when a tree class' do

      context 'when not a Tree subclass' do
        specify { expect { tree.child_constructor = String }.to raise_error ArgumentError }
      end

      context 'when a Tree subclass' do
        let(:tree_class) { Class.new(Sycamore::Tree) }
        before { tree.child_constructor = tree_class }
        specify { expect(tree.child_constructor).to eql tree_class }
        specify { expect(tree.child_class).to eql tree_class }
      end

    end

    context 'when a generator proc' do
      before(:each) do
        tree.def_child_generator { Sycamore::Tree[42] }
      end

      specify { expect(tree.child_constructor).to be_a Proc }
      specify { expect(tree.child_generator).to be_a Proc }
      specify { expect(tree.child_constructor.call).to be === Sycamore::Tree[42] }
    end

  end

end
