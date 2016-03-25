require 'delegate'

module Sycamore

  ##
  # An Absence object represents the absence of a specific child {Sycamore::Tree}.
  #
  # +Absence+ instances get created when accessing non-existent children of a
  # Tree with {Tree#child_of} or {Tree#child_at}.
  # It is not intended to be instantiated by the user.
  #
  # An +Absence+ object can be used like a normal {Sycamore::Tree}.
  # {Tree::QUERY_METHODS Query} and {Tree::DESTRUCTIVE_COMMAND_METHODS pure destructive command method}
  # calls get delegated to {Sycamore::Nothing}, i.e. will behave like an empty Tree.
  # On every other {Tree::COMMAND_METHODS command} calls, the +Absence+ object
  # gets resolved, which means the missing tree will be created, added to the
  # parent tree and the method call gets delegated to the now existing tree.
  # After the +Absence+ object is resolved all subsequent method calls are
  # delegated to the created tree.
  # The type of tree eventually created is determined by the {Tree#new_child}
  # implementation of the parent tree and the parent node.
  #
  class Absence < Delegator

    ##
    # @api private
    #
    def initialize(parent_tree, parent_node)
      @parent_tree, @parent_node = parent_tree, parent_node
    end

    class << self
      alias at new
    end

    ########################################################################
    # presence creation
    ########################################################################

    ##
    # The tree object to which all method calls are delegated.
    #
    # @api private
    #
    def presence
      @tree or Nothing
    end

    alias __getobj__ presence

    ##
    # @api private
    #
    def create
      @parent_tree = @parent_tree.add_node_with_empty_child(@parent_node)
      @tree = @parent_tree[@parent_node]
    end

    ########################################################################
    # Absence and Nothing predicates
    ########################################################################

    ##
    # (see Tree#absent?)
    #
    def absent?
      @tree.nil?
    end

    ##
    # (see Tree#nothing?)
    #
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
        raise InvalidNode, "#{node} is not a valid tree node" if node.is_a? Enumerable

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

    ##
    # A developer-friendly string representation of the absent tree.
    #
    # @return [String]
    #
    def inspect
      "#{absent? ? 'absent' : 'present'} child of node #{@parent_node.inspect} in #{@parent_tree.inspect}"
    end

    ##
    # Duplicates the resolved tree or raises an error, when unresolved.
    #
    # @return [Tree]
    #
    # @raise [TypeError] when this {Absence} is not resolved yet
    #
    def dup
      presence.dup
    end

    ##
    # Clones the resolved tree or raises an error, when unresolved.
    #
    # @return [Tree]
    #
    # @raise [TypeError] when this {Absence} is not resolved yet
    #
    def clone
      presence.clone
    end

    ##
    # Checks if the absent tree is frozen.
    #
    # @return [Boolean]
    #
    def frozen?
      if absent?
        false
      else
        presence.frozen?
      end
    end

    #####################
    #  command methods  #
    #####################

    # TODO: YARD should be informed about this method definitions.
    Tree.command_methods.each do |command_method|
      if Tree.pure_destructive_command_methods.include?(command_method)
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
