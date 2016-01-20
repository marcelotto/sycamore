describe Sycamore::Tree do

  # TODO: shared example or matcher for ...
  describe '#to_???' do
    specify { expect( Sycamore::Tree[         ].to_h ).to eq( {} ) }
    specify { expect( Sycamore::Tree[ 1       ].to_h ).to eq( 1 ) }
    specify { expect( Sycamore::Tree[ 1, 2, 3 ].to_h ).to eq( [1, 2, 3] ) }
    specify { expect( Sycamore::Tree[ :a => 1 ].to_h ).to eq( { :a => 1 } ) }
    specify { expect( Sycamore::Tree[ :a => 1, :b => [2, 3] ].to_h ).to eq(
                                                                          { :a => 1, :b => [2, 3] } ) }
  end

  # describe '#to_a' do
  #   specify { expect( Sycamore::Tree[         ].to_a ).to eq( [] ) }
  #   specify { expect( Sycamore::Tree[ 1       ].to_a ).to eq( [1] ) }
  #   specify { expect( Sycamore::Tree[ 1, 2, 3 ].to_a ).to eq( [1, 2, 3] ) }
  #   specify { expect( Sycamore::Tree[ :a => 1 ].to_a ).to eq( [ :a => [1] ] ) }
  #   specify { expect( Sycamore::Tree[ :a => 1, :b => [2, 3] ].to_a ).to eq(
  #                                   [ :a => [1], :b => [2, 3] ] ) }
  # end

  describe '#to_h' do
    pending
  end

  describe '#to_s' do
    it 'delegates to the hash representation of #to_h'
    # TODO: shared example or matcher for ...

    specify { expect( Sycamore::Tree[         ].to_s ).to eq( '{}' ) }
    specify { expect( Sycamore::Tree[ 1       ].to_s ).to eq( '1' ) }
    specify { expect( Sycamore::Tree[ 1, 2, 3 ].to_s ).to eq( '[1, 2, 3]' ) }
    specify { expect( Sycamore::Tree[ :a => 1 ].to_s ).to eq( '{:a=>1}' ) }
    specify { expect( Sycamore::Tree[ :a => 1, :b => [2, 3] ].to_s ).to eq(
                                                                          '{:a=>1, :b=>[2, 3]}' ) }

  end

  describe '#inspect' do

    shared_examples_for 'every inspect string' do |tree|
      it 'is in the usual Ruby inspect style' do
        expect( tree.inspect ).to match /^#<Sycamore::Tree:0x/
      end
      it 'contains the object identity' do
        expect( tree.inspect ).to include tree.object_id.to_s(16)
      end
      it 'contains the hash representation' do
        expect( tree.inspect ).to include tree.to_h.inspect
      end
    end

    include_examples 'every inspect string', Sycamore::Tree.new
    include_examples 'every inspect string', Sycamore::Tree[1,2,3]
    include_examples 'every inspect string', Sycamore::Tree[foo: 1, bar: [2,3]]

  end

end
