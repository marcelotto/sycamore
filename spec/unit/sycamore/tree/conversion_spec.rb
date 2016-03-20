describe Sycamore::Tree do

  describe '#to_native_object' do
    it 'does return the an empty array, when empty' do
      expect( Sycamore::Tree.new.to_native_object ).to eql []
    end

    it 'does return a hash, with leaves having an empty array as a child' do
      expect( Sycamore::Tree[1=>[], 2=>{}].to_native_object ).to eql( {1=>[], 2=>[]} )
    end

    it 'does return a hash, with strict leaves having no child' do
      expect( Sycamore::Tree[1   ].to_native_object ).to eql( 1)
      expect( Sycamore::Tree[1, 2].to_native_object ).to eql( [1, 2] )
    end
  end

  ############################################################################

  describe '#to_h' do

    it 'does return a hash, where the first level is unflattened and the rest flattened' do
      expect( Sycamore::Tree[a: 1            ].to_h ).to eql( {a: 1} )
      expect( Sycamore::Tree[:a, b: 1        ].to_h ).to eql( {a: nil, b: 1} )
      expect( Sycamore::Tree[a: 1, b: [2, 3] ].to_h ).to eql( {a: 1, b: [2, 3]} )
      expect( Sycamore::Tree[a: {b: nil, c: { }}].to_h ).to eql( {a: {b: nil, c: []}} )
      expect( Sycamore::Tree[a: {b: nil, c: [1]}].to_h ).to eql( {a: {b: nil, c: 1}} )
    end

    context 'first level' do
      it 'does return an empty hash, when empty' do
        expect( Sycamore::Tree.new.to_h ).to eql Hash.new
      end

      it 'does return a hash, with leaves having an empty array as a child' do
        expect( Sycamore::Tree[1=>[], 2=>[]].to_h ).to eql( {1=>[], 2=>[]} )
      end

      it 'does return a hash, with strict leaves having nil as a child' do
        expect( Sycamore::Tree[1   ].to_h ).to eql( {1 => nil} )
        expect( Sycamore::Tree[1, 2].to_h ).to eql( {1 => nil, 2 => nil} )
      end
    end
  end

  ############################################################################

  describe '#to_s' do
    shared_examples_for 'every to_s string' do |tree|
      it 'starts with a Tree-specific prefix' do
        expect( tree.to_s ).to match /^#<Tree\[ /
      end
      it 'contains the flattened hash to_s representation' do
        expect( tree.to_s ).to include tree.to_native_object.to_s
      end
    end
    include_examples 'every to_s string', Sycamore::Tree.new
    include_examples 'every to_s string', Sycamore::Tree['foo']
    include_examples 'every to_s string', Sycamore::Tree[1.0, 2, 3]
    include_examples 'every to_s string', Sycamore::Tree[:foo, bar: [2,3]]
    include_examples 'every to_s string', Sycamore::Tree[foo: 1, bar: [], baz: nil]
  end

  ############################################################################

  describe '#inspect' do
    shared_examples_for 'every inspect string' do |tree|
      it 'is in the usual Ruby inspect style' do
        expect( tree.inspect ).to match /^#</
      end
      it 'contains the class' do
        expect( tree.inspect ).to include tree.class.to_s
      end
      it 'contains the object identity' do
        expect( tree.inspect ).to include tree.object_id.to_s(16)
      end
      it 'contains inspect string representation of the expanded to_h representation' do
        expect( tree.inspect ).to include tree.to_h.inspect
      end
    end
    include_examples 'every inspect string', Sycamore::Tree.new
    include_examples 'every inspect string', Sycamore::Tree[1,2,3]
    include_examples 'every inspect string', Sycamore::Tree[foo: 1, bar: [2,3]]
    include_examples 'every inspect string', Sycamore::Tree[foo: 1, bar: [], baz: nil]
    include_examples 'every inspect string', (MyClass = Class.new(Sycamore::Tree)).new
  end

end
