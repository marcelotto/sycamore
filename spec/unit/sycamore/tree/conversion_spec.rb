describe Sycamore::Tree do

  describe '#to_h' do
    it 'does return the an empty hash, when empty' do
      expect( Sycamore::Tree.new.to_h ).to eql Hash.new
    end

    context 'when the tree consists of leaves only' do
      it 'does return a hash, where the leaves have an empty hash as its value' do
        expect( Sycamore::Tree[1   ].to_h ).to eql( {1 => {}} )
        expect( Sycamore::Tree[1, 2].to_h ).to eql( {1 => {}, 2 => {}} )
      end
    end

    context 'when the tree has at least one node with children' do
      it 'does return a hash, where the leaves at deeper levels are represented directly' do
        expect( Sycamore::Tree[a: 1            ].to_h ).to eql( {a: 1} )
        expect( Sycamore::Tree[:a, b: 1        ].to_h ).to eql( {a: {}, b: 1} )
        expect( Sycamore::Tree[a: 1, b: [2, 3] ].to_h ).to eql( {a: 1, b: [2, 3]} )
      end
    end
  end

  describe '#to_s' do
    shared_examples_for 'every to_s string' do |tree|
      it 'starts with a Tree-specific prefix' do
        expect( tree.to_s ).to match /^#<Tree: /
      end
      it 'contains the flattened hash to_s representation' do
        expect( tree.to_s ).to include tree.to_h(flattened: true).to_s
      end
    end
    include_examples 'every to_s string', Sycamore::Tree.new
    include_examples 'every to_s string', Sycamore::Tree['foo']
    include_examples 'every to_s string', Sycamore::Tree[1.0, 2, 3]
    include_examples 'every to_s string', Sycamore::Tree[foo: 1, bar: [2,3]]
    include_examples 'every to_s string', Sycamore::Tree[:foo, bar: [2,3]]
  end

  describe '#inspect' do
    shared_examples_for 'every inspect string' do |tree|
      it 'is in the usual Ruby inspect style' do
        expect( tree.inspect ).to match /^#<Sycamore::Tree:0x/
      end
      it 'contains the object identity' do
        expect( tree.inspect ).to include tree.object_id.to_s(16)
      end
      it 'contains the flattened hash inspect representation' do
        expect( tree.inspect ).to include tree.to_h(flattened: true).inspect
      end
    end
    include_examples 'every inspect string', Sycamore::Tree.new
    include_examples 'every inspect string', Sycamore::Tree[1,2,3]
    include_examples 'every inspect string', Sycamore::Tree[foo: 1, bar: [2,3]]
  end

end
