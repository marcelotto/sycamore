require 'singleton'

module Sycamore

  ############################################################################
  # The Nothing Tree singleton class
  #
  # The Nothing Tree is an empty Sycamore Tree, and means "there are no nodes".
  #
  # It is immutable:
  # - Query method calls, will behave like a normal, empty Tree.
  # - Destructive command calls, will be ignored, i.e. being no-ops.
  # - But all additive command calls, will raise a NothingAdditionError < NothingAccessError # TODO
  #
  # It is the only Tree object that will `true` on a #nothing call.
  # But like Absence, it will return `true` on #absent? and `false` on #present?.
  #
  class NothingTree < Tree
    include Singleton

    ########################################################################
    # Absence and Nothing predicates
    ########################################################################

    # @see {Tree#nothing?}
    def nothing?
      query_return true
    end

    # @see {Tree#present?}
    def present?
      query_return false
    end

    # @see {Tree#absent?}
    def absent?
      query_return true
    end

    ########################################################################
    # CQS element access
    ########################################################################

    # TODO: YARD should be informed about this method definitions.
    command_methods.each do |command_method|
      define_method command_method do |*args|
        raise NothingMutation, 'attempt to change the Nothing tree'
      end
    end

    # TODO: YARD should be informed about this method definitions.
    destructive_command_methods.each do |command_method|
      define_method command_method do |*args|
        command_return
      end
    end

    # the unique string representation of the Nothing Singleton
    #
    # @return [String] '#<Sycamore::Nothing>'
    #
    def inspect
      '#<Sycamore::Nothing>'
    end


    ########################################################################
    # Falsiness
    #
    # Sadly, in Ruby we can't do that match to reach this goal.
    #
    # see http://devblog.avdi.org/2011/05/30/null-objects-and-falsiness/
    ########################################################################

    # trying to emulate a falsey value, by negating to true
    #
    # @return [Boolean] true
    # @see http://devblog.avdi.org/2011/05/30/null-objects-and-falsiness/
    #
    def !
      true
    end

    # def nil?
    #   true
    # end

  end

  ############################################################################
  # The Nothing Tree Singleton object
  #
  # @todo Use Adamantium (or something similar) to make the nothing tree immutable?
  #   Optionally. Configurable. We won't have any other dependencies.
  #
  Nothing = NothingTree.instance.freeze

end
