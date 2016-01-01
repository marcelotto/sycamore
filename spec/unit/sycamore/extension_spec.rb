describe 'the global Tree constant' do

  describe '#initialize' do
    context 'when called via an unqualified Tree.new' do
      context "before requiring 'sycamore/extension'" do
        it 'raises a NameError' do
          expect { Tree.new }.to raise_error NameError
        end
      end

      context "after requiring 'sycamore/extension'" do
        before {
          # TODO: "We must ensure it's not required yet"
          require 'sycamore/extension' }
        it 'creates a Tree' do
          expect( Tree.new ).to be_a Sycamore::Tree
        end
      end
    end
  end
end
