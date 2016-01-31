require 'delegate'

module Sycamore
  class Absence < Delegator

    def initialize(parent_tree, parent_node)
      @parent_tree, @parent_node = parent_tree, parent_node
    end

    class << self
      alias at new
    end

    ########################################################################
    # presence creation
    ########################################################################

    def presence
      @tree or Nothing
    end

    alias __getobj__ presence

    def create
      @parent_tree = @parent_tree.create_child(@parent_node)
      @tree = @parent_tree[@parent_node]
    end

    ########################################################################
    # Absence and Nothing predicates
    ########################################################################

    # @see {Tree#absent?}
    def absent?
      @tree.nil?
    end

    def nothing?
      false
    end

    ########################################################################
    # Element access
    ########################################################################

    #####################
    #   query methods   #
    #####################

    def child_of(node)
      if absent?
        raise IndexError, 'nil is not a valid tree node' if node.nil?

        Absence.at(self, node)
      else
        presence.child_of(node)
      end
    end

    def child_at(*path)
      if absent?
        # TODO: This is duplication of Tree#child_at! How can we remove it, without introducing a module for this single method or inherit from Tree?
        case path.length
          when 0 then raise ArgumentError, 'wrong number of arguments (given 0, expected 1+)'
          when 1 then child_of(*path)
          else child_of(path[0]).child_at(*path[1..-1])
        end
      else
        presence.child_at(*path)
      end
    end

    alias [] child_at
    alias dig child_at

    def inspect
      "#<Sycamore::Absence.at(#@parent_tree, #@parent_node)>"
      "#{absent? ? 'absent' : 'present'} child tree of node #{@parent_node.inspect} in #{@parent_tree.inspect}"
    end

    #####################
    #  command methods  #
    #####################

    # TODO: YARD should be informed about this method definitions.
    Tree.command_methods.each do |command_method|
      if Tree.destructive_command_methods.include?(command_method)
        define_method command_method do |*args|
          if absent?
            self
          else
            presence.send(command_method, *args) # TODO: How can we hand over a possible block? With eval etc.?
          end
        end
      else
        # TODO: This method should be atomic.
        define_method command_method do |*args|
          create if absent?
          presence.send(command_method, *args) # TODO: How can we hand over a possible block? With eval etc.?
        end
      end
    end

  end
end
