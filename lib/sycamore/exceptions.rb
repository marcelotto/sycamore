module Sycamore
  # raised when trying to add an Enumerable to the nodes of a tree
  class NestedNodeSet < StandardError ; end
  # raised when trying to call a command method of the {Nothing} tree
  class UnhandledNothingAccess < StandardError ; end
end
