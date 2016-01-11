describe Sycamore::Tree do

  describe '#hash' do
    specify { expect( Sycamore::Tree.new.hash   == Sycamore::Tree.new.hash      ).to be true }
    specify { expect( Sycamore::Tree[1].hash    == Sycamore::Tree[1].hash       ).to be true }
    specify { expect( Sycamore::Tree[1].hash    == Sycamore::Tree[2].hash       ).to be false }
    specify { expect( Sycamore::Tree[1,2].hash  == Sycamore::Tree[2,1].hash     ).to be true }
    specify { expect( Sycamore::Tree[a: 1].hash == Sycamore::Tree[a: 1].hash    ).to be true }
    specify { expect( Sycamore::Tree[a: 1].hash == Sycamore::Tree[a: 2].hash    ).to be false }
    specify { expect( Sycamore::Tree[a: 1].hash == Sycamore::Tree[b: 1].hash    ).to be false }
    specify { expect( Sycamore::Tree[1].hash    == Sycamore::Tree[1 => nil].hash).to be true }

    specify { expect( Sycamore::Tree.new.hash   == Hash.new.hash  ).to be false }
    specify { expect( Sycamore::Tree[a: 1].hash == Hash[a: 1].hash).to be false }
  end

  ############################################################################

  describe '#eql?' do
    specify { expect( Sycamore::Tree.new   ).to eql     Sycamore::Tree.new }
    specify { expect( Sycamore::Tree[1]    ).to eql     Sycamore::Tree[1] }
    specify { expect( Sycamore::Tree[1]    ).not_to eql Sycamore::Tree[2] }
    specify { expect( Sycamore::Tree[1,2]  ).to eql     Sycamore::Tree[2,1] }
    specify { expect( Sycamore::Tree[a: 1] ).to eql     Sycamore::Tree[a: 1] }

    specify { expect( Sycamore::Tree[a: 1] ).not_to eql Hash[a: 1] }
    specify { expect( Sycamore::Tree[1]    ).not_to eql Hash[1 => nil] }
  end

  ############################################################################

  describe '#==' do

    pending 'What should be the semantics of #==?'

    #   Currently it is the same as eql?, since Hash
    #    coerces only the values and not the keys ...

    specify { expect( Sycamore::Tree.new   ).to eq     Sycamore::Tree.new }
    specify { expect( Sycamore::Tree[1]    ).to eq     Sycamore::Tree[1] }
    specify { pending ; expect( Sycamore::Tree[1]    ).to eq     Sycamore::Tree[1.0] }
    specify { expect( Sycamore::Tree[1]    ).not_to eq Sycamore::Tree[2] }
    specify { expect( Sycamore::Tree[1,2]  ).to eq     Sycamore::Tree[2,1] }
    specify { expect( Sycamore::Tree[2]    ).to eq     Sycamore::Tree[1 => 2][1]   }
    specify { expect( Sycamore::Tree[a: 1] ).to eq     Sycamore::Tree[a: 1] }

    specify { expect( Sycamore::Tree[a: 1] ).not_to eq Hash[a: 1] }
    specify { expect( Sycamore::Tree[1]    ).not_to eq Hash[1 => nil] }
  end

  describe '#===' do
    context 'when the other is an atom' do
      context 'when it matches the other' do
        specify { expect( Sycamore::Tree[1]    ===  1   ).to be true }
        specify { expect( Sycamore::Tree[:a]   === :a   ).to be true }
        specify { expect( Sycamore::Tree['a']  === 'a'  ).to be true }
      end

      context 'when it not matches the other' do
        specify { expect( Sycamore::Tree[1]  === 2   ).to be false }
        specify { expect( Sycamore::Tree[1]  === '1' ).to be false }
        specify { expect( Sycamore::Tree[:a] === 'a' ).to be false }
      end
    end

    context 'when the other is an Enumerable' do
      context 'when it matches the other' do
        specify { expect( Sycamore::Tree[1] === [1]               ).to be true }
        specify { expect( Sycamore::Tree[1,2,3] === [1,2,3]       ).to be true }
        specify { expect( Sycamore::Tree[:a,:b,:c] === [:c,:a,:b] ).to be true }
      end

      context 'when it not matches the other' do
        specify { expect( Sycamore::Tree[1,2]   === [1,2,3]   ).to be false }
        specify { expect( Sycamore::Tree[1,2,3] === [1,2]     ).to be false }
        specify { expect( Sycamore::Tree[1,2,3] === [1,2,[3]] ).to be false }
      end
    end

    context 'when the other is Tree-like' do
      context 'when it matches the other' do
        specify { expect( Sycamore::Tree.new   === Sycamore::Tree.new ).to be true }
        specify { expect( Sycamore::Tree.new   === Hash.new ).to be true }
        specify { expect( Sycamore::Tree.new   === Sycamore::Tree[nil] ).to be true }
        specify { expect( Sycamore::Tree.new   === Sycamore::Tree[nil => nil] ).to be true }
        specify { expect( Sycamore::Tree.new   ===
                            Sycamore::Tree[Sycamore::Nothing => Sycamore::Nothing] ).to be true }
        specify { expect( Sycamore::Tree[1]    === Sycamore::Tree[1] ).to be true }
        specify { expect( Sycamore::Tree[1]    === Sycamore::Tree[1 => nil] ).to be true }
        specify { expect( Sycamore::Tree[1]    === Hash[1 => nil] ).to be true }
        specify { expect( Sycamore::Tree[1]    ===
                            Sycamore::Tree[1 => Sycamore::Nothing] ).to be true }
        specify { expect( Sycamore::Tree[1]    ===
                            Hash[1 => Sycamore::Nothing] ).to be true }
        specify { expect( Sycamore::Tree[1,2]  === Sycamore::Tree[2,1] ).to be true }
        specify { expect( Sycamore::Tree[a: 1] === Sycamore::Tree[a: 1] ).to be true }
        specify { expect( Sycamore::Tree[a: 1] === Hash[a: 1] ).to be true }
        specify { expect( Sycamore::Tree[foo: 'foo', bar: ['bar', 'baz']] ===
                            Sycamore::Tree[foo: 'foo', bar: ['bar', 'baz']] ).to be true }
        specify { expect( Sycamore::Tree[foo: 'foo', bar: ['bar', 'baz']] ===
                            Hash[foo: 'foo', bar: ['bar', 'baz']] ).to be true }
        specify { expect( Sycamore::Tree[1=>{2=>{3=>4}}] ===
                            Sycamore::Tree[1=>{2=>{3=>4}}] ).to be true }
        specify { expect( Sycamore::Tree[1=>{2=>{3=>4}}] ===
                            Hash[1=>{2=>{3=>4}}] ).to be true }
        specify { expect( Sycamore::Tree[a: 1] === Hash[a: 1] ).to be true }
      end

      context 'when it not matches the other' do
        specify { expect( Sycamore::Tree.new   ===
                            Hash[nil => nil] ).to be false }
        specify { expect( Sycamore::Tree.new   ===
                            Hash[Sycamore::Nothing => Sycamore::Nothing] ).to be false }
        specify { expect( Sycamore::Tree[1]    ===
                            Sycamore::Tree[2]).to be false }
        specify { expect( Sycamore::Tree[1=>{2=>{3=>4}}] ===
                            Sycamore::Tree[1=>{2=>{3=>1}}] ).to be false }
        specify { expect( Sycamore::Tree[1=>{2=>{3=>4}}] ===
                            Hash[1=>{2=>{4=>4}}] ).to be false }
      end
    end
  end

end
