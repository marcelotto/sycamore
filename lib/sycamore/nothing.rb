require 'singleton'

module Sycamore

  ############################################################################
  # The Nothing Tree Singleton
  #
  # It is a normal empty Sycamore Tree, that is immutable.
  #
  class NothingTree < Tree
    include Singleton

    command_methods.each do |command_method|
      define_method command_method do |*args|
        # TODO: Streamline this, with how Ruby reacts with
        #   an attempt to edit a frozen object:
        # raise RuntimeError, "can't modify Nothing"
        raise UnhandledNothingAccess
      end
    end

    private def command_return
      raise NothingAccessPerformed
    end

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

    def !
      true
    end

    # def nil?
    #   true
    # end

  end

  Nothing = NothingTree.instance.freeze

end
