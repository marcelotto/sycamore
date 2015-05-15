require 'singleton'

module Sycamore

  ############################################################################
  # The Nothing Tree Singleton class
  #
  # It is a normal empty Sycamore Tree, that is immutable.
  #
  class NothingTree < Tree
    include Singleton

    # TODO: YARD should be informed about this method definitions.
    command_methods.each do |command_method|
      define_method command_method do |*args|
        raise UnhandledNothingAccess
      end
    end

    # as Nothing already is "clear", this command method doesn't do any harm
    #
    def clear
      command_return
    end

    # the unique string representation of the Nothing Singleton
    #
    # @return [String] '#<Sycamore::Nothing>'
    #
    def to_s
      '#<Sycamore::Nothing>'
    end

    alias inspect to_s


    ####################################################################
    # Falsiness
    #
    # Sadly, in Ruby we can't do that match to reach this goal.
    #
    # see http://devblog.avdi.org/2011/05/30/null-objects-and-falsiness/
    ####################################################################

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
  Nothing = NothingTree.instance.freeze

end
