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
      true
    end

    # @see {Tree#absent?}
    def absent?
      true
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
    pure_destructive_command_methods.each do |command_method|
      define_method(command_method) { |*args| self }
    end

    def child_of(node)
      self
    end

    def to_s
      '#<Tree: Nothing>'
    end

    # the unique string representation of the Nothing tree
    #
    # @return [String] '#<Sycamore::Nothing>'
    #
    def inspect
      '#<Sycamore::Nothing>'
    end

    def freeze
      super
    end

    ########################################################################
    # Equality
    ########################################################################

    def ==(other)
      (other.is_a?(Tree) or other.is_a?(Absence)) and other.empty?
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


    ########################################################################
    # Some helpers
    #
    # Ideally these would be implemented with Refinements, but since they
    # aren't available anywhere (I'm looking at you, JRuby), we have to be
    # content with this.
    #
    ########################################################################

    def like?(object)
      object.nil? or object.equal? self
    end

  end

  ############################################################################
  # The Nothing Tree Singleton object
  #
  Nothing = NothingTree.instance.freeze

end
