require 'singleton'

module Sycamore

  ##
  # The Nothing Tree singleton class.
  #
  # The Nothing Tree is an empty Sycamore Tree, and means "there are no nodes".
  #
  # It is immutable:
  # - {Tree::QUERY_METHODS Query method} calls will behave like a normal, empty Tree.
  # - {Tree::DESTRUCTIVE_COMMAND_METHODS Pure destructive command} calls, will be ignored, i.e. being no-ops.
  # - But all other {Tree::COMMAND_METHODS command} calls, will raise a {NothingMutation}.
  #
  # It is the only Tree object that will return +true+ on a {#nothing?} call.
  # But like {Absence}, it will return +true+ on {#absent?} and +false+ on {#existent?}.
  #
  class NothingTree < Tree
    include Singleton

    ########################################################################
    # Absence and Nothing predicates
    ########################################################################

    ##
    # (see Tree#nothing?)
    #
    def nothing?
      true
    end

    ##
    # (see Tree#absent?)
    #
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

    def to_native_object
      nil
    end

    ##
    # A string representation of the Nothing tree.
    #
    # @return [String]
    #
    def to_s
      '#<Tree: Nothing>'
    end

    ##
    # A developer-friendly string representation of the Nothing tree.
    #
    # @return [String]
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

    ##
    # Checks if the given object is an empty tree.
    #
    # @return [Boolean]
    #
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

    ##
    # Try to emulate a falsey value, by negating to +true+.
    #
    # @return [Boolean] +true+
    #
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
