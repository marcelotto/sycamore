module Sycamore
  # raised when trying to call a command method of the {Nothing} tree
  class UnhandledNothingAccess < StandardError ; end
end
