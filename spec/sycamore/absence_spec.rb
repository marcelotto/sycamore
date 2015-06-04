describe Sycamore::Absence do

  describe '#present?' do
    it 'does return false' do
      expect(Sycamore::Absence.new().present?).to be false
    end
  end

  describe '#absent?' do
    it 'does return true' do
      expect(Sycamore::Absence.new().absent?).to be true
    end
  end

  describe '#nothing?' do
    skip 'What should be the semantics of Absence#nothing?'
    it 'does depend on the wrapped tree?'
    it 'does return false?' do
      pending
      expect(Sycamore::Absence.new().nothing?).to be false
    end
  end

end
