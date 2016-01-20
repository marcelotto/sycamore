describe Sycamore::Tree do

  # TODO: Replace RSpec yield matchers! All?

  describe '#each' do

    context 'when a block given' do
      context 'when empty' do
        specify { expect { |b| Sycamore::Tree[].each(&b) }.not_to yield_control }
      end

      context 'when the block has arity 2' do

        context 'when having one leaf' do
          specify { expect { |b| Sycamore::Tree[1].each(&b) }.to yield_with_args([1, nil]) } #
          specify { pending ; expect { |b| Sycamore::Tree[1].each(&b) }.to yield_with_args(1, nil) }
          specify { pending '???' ; expect { |b| Sycamore::Tree[1 => 2].each(&b) }.to yield_with_args(1, Sycamore::Tree[2]) }
          # specify { pending 'this calls implicitely to_a' ; expect { |b| Sycamore::Tree[1 => 2].each(&b) }.to yield_with_args([1, Tree[2]]) }
          # specify { expect { |b| Sycamore::Tree[1 => 2].each(&b) }.to yield_with_args(1, Sycamore::Tree[2]) }
          specify { expect { |b| Sycamore::Tree[1 => 2].each(&b) }.to yield_with_args([1, Sycamore::Tree[2]]) }
          specify { expect { |b| Sycamore::Tree[1].each(&b) }.to yield_control.exactly(1).times }
          specify { expect { |b| Sycamore::Tree[1].each(&b) }.to yield_successive_args([1, nil]) }
        end

        context 'when having more leaves' do
          specify { expect { |b| Sycamore::Tree[1,2,3].each(&b) }.to yield_control.exactly(3).times }
          specify { expect { |b| Sycamore::Tree[1,2,3].each(&b) }.to yield_successive_args([1, nil], [2, nil], [3, nil]) }
        end

        context 'when having nodes with children' do
          # specify { expect( Sycamore::Tree[a: 1, b: nil].size ).to be 2 }
        end

      end

      context 'when the block has arity <=1' do

        context 'when having one leaf' do
          specify { pending 'replace RSpec yield matchers' ; expect { |b| Sycamore::Tree[1].each(&b) }.to yield_with_args(1) } #
          specify { pending 'replace RSpec yield matchers' ; expect { |b| Sycamore::Tree[1 => 2].each(&b) }.to yield_with_args(1) }
          # specify { pending 'this calls implicitely to_a' ; expect { |b| Sycamore::Tree[1 => 2].each(&b) }.to yield_with_args([1, Sycamore::Tree[2]]) }
          # specify { expect { |b| Sycamore::Tree[1 => 2].each(&b) }.to yield_with_args(1, Sycamore::Tree[2]) }
          specify { expect { |b| Sycamore::Tree[1 => 2].each(&b) }.to yield_with_args([1, Sycamore::Tree[2]]) }
        end

        context 'when having more leaves' do
        end

        context 'when having nodes with children' do
          # specify { expect( Sycamore::Tree[a: 1, b: nil].size ).to be 2 }
        end

      end


    end

    context 'when no block given' do
      pending
    end

  end

  ############################################################################

  describe '#each_path' do
    specify { expect(Sycamore::Tree[1     ].paths.to_a ).to eq [Sycamore::Path[1]] }
    specify { expect(Sycamore::Tree[1,2   ].paths.to_a ).to eq [Sycamore::Path[1], Sycamore::Path[2]] }
    specify { expect(Sycamore::Tree[1 => 2].paths.to_a ).to eq [Sycamore::Path[1, 2]] }
    specify { expect(Sycamore::Tree[1 => { 2 => [3, 4] }].paths.to_a )
                .to eq [Sycamore::Path[1, 2, 3], Sycamore::Path[1, 2, 4]] }
  end

end
