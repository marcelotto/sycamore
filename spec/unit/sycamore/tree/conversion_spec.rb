describe Sycamore::Tree do

  describe '#to_native_object' do
    it 'does return an empty array, when empty' do
      expect( Sycamore::Tree.new.to_native_object ).to eql []
    end

    it 'does return a hash, with leaves having an empty array as a child' do
      expect( Sycamore::Tree[1=>[], 2=>{}].to_native_object ).to eql( {1=>[], 2=>[]} )
    end

    it 'does return a hash, with strict leaves having no child' do
      expect( Sycamore::Tree[1   ].to_native_object ).to eql 1
      expect( Sycamore::Tree[1, 2].to_native_object ).to eql [1, 2]
    end

    context 'edge cases' do
      specify { expect( Sycamore::Tree[nil  ].to_native_object ).to eql nil }
      specify { expect( Sycamore::Tree[false].to_native_object ).to eql false }
      specify { expect( Sycamore::Tree[true ].to_native_object ).to eql true }
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

    context 'edge cases' do
      it 'does treat nil like any other value' do
        expect( Sycamore::Tree[nil => 1].to_h ).to eql( {nil => 1} )
        expect( Sycamore::Tree[nil => [], 2 => []].to_h ).to eql( {nil => [], 2 => []} )
        expect( Sycamore::Tree[nil].to_h ).to eql( {nil => nil} )
        expect( Sycamore::Tree[nil => [nil]].to_h ).to eql( {nil => nil} )
        expect( Sycamore::Tree[nil => {nil => nil}].to_h ).to eql( {nil => nil} )
      end
    end
  end

  ############################################################################

  describe '#to_s' do
    module ContextWithTreeConstant
      Tree = Sycamore::Tree
    end

    shared_examples_for 'every to_s string' do |tree|
      it 'starts with a Tree-specific prefix' do
        expect( tree.to_s ).to match /^Tree\[/
      end

      it 'evaluates to the original Tree, when all nodes contained have this property' do
        expect( ContextWithTreeConstant.module_eval(tree.to_s) ).to eql tree
      end
    end

    shared_examples_for 'every to_s string (single leaf)' do |tree|
      include_examples 'every to_s string', tree
      it 'contains the nodes inspect representation' do
        expect( tree.to_s ).to include tree.node.inspect
      end
    end

    shared_examples_for 'every to_s string (non-single leaf)' do |tree|
      include_examples 'every to_s string', tree
      it 'contains the to_s representation of the hash representation without brackets' do
        expect( tree.to_s ).to include tree.to_native_object.to_s[1..-2]
      end
    end

    include_examples 'every to_s string (single leaf)',     Sycamore::Tree['foo']
    include_examples 'every to_s string (single leaf)',     Sycamore::Tree[nil]
    include_examples 'every to_s string (non-single leaf)', Sycamore::Tree.new
    include_examples 'every to_s string (non-single leaf)', Sycamore::Tree[1.0, 2, 3]
    include_examples 'every to_s string (non-single leaf)', Sycamore::Tree[foo: [1,2]]
    include_examples 'every to_s string (non-single leaf)', Sycamore::Tree[:foo, bar: [2,3]]
    include_examples 'every to_s string (non-single leaf)', Sycamore::Tree[foo: 1, bar: [], baz: nil, qux: {}]
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
