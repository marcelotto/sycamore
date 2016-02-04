module Sycamore
  # raised when a value is not a valid node
  class InvalidNode < ArgumentError ; end
  # raised when trying to call a additive command method of the {Nothing} tree
  class NothingMutation < StandardError ; end
  # raised when calling {Tree#node} on a Tree with multiple nodes
  class NonUniqueNodeSet < StandardError ; end
end
