module Sycamore
  class Absence

    # @see {Tree#present?}
    def present?
      false
    end

    # @see {Tree#absent?}
    def absent?
      true
    end

  end
end
