module Sycamore
  # raised when a value is not a valid node
  class InvalidNode < ArgumentError ; end

  # raised when trying to call a additive command method of the {Nothing} tree
  class NothingMutation < StandardError ; end

  # raised when calling {Tree#node} or {Tree#node!} on a Tree with multiple nodes
  class NonUniqueNodeSet < StandardError ; end

  # raised when calling {Tree#node!} on a Tree without nodes
  class EmptyNodeSet < StandardError ; end

  # raised when trying to fetch the child of a leaf
  class ChildError < KeyError ; end
end
