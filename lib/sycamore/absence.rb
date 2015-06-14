require 'delegate'

module Sycamore
  class Absence < Delegator

    def initialize(parent_tree, parent_node)
      raise ArgumentError if not (parent_tree.is_a?(Tree) or
                                  parent_tree.is_a?(Absence)) or not parent_node
      @parent_tree, @parent_node = parent_tree, parent_node
    end

    def self.at(parent_tree, parent_node)
      Absence.new(parent_tree, parent_node)
    end


    ###################################################################
    # predicates
    ###################################################################

    # @see {Tree#absent?}
    def absent?
      not present?
    end

    # @see {Tree#present?}
    def present?
      not @tree.nil? # TODO: TDD this: and not @tree.nothing?
    end

    def nothing?
      false
      # TODO: TDD this: @tree.equal? Nothing
    end

    def absent_parent?
      @parent_tree.is_a? Absence
    end

    ###################################################################
    # state
    #
    # TODO: How can we enforce the invariant that #created? and #installed?,
    #   must always be equal and therefore synonym?
    ###################################################################

=begin
    STATES = %i[requested created installed negated]

    def state
      case
        when requested? then :requested
        when created?   then :created
        when installed? then :installed
        # TODO: when negated?   then :negated
        # TODO: else raise InvalidState, ''
      end
    end
=end

    def requested?
      absent? and not nothing?
    end

    def created?
      present? and not nothing?
    end

    def installed?
      @tree.equal? @parent_tree[@parent_node]
    end


    ###################################################################
    # presence creation
    ###################################################################

    def presence
      @tree or Nothing
    end

    private def create_presence
      # TODO: handle different states? if requested? or installed? ...
      @tree ||= Tree.new
    end

    private def install_presence
      @parent_tree = @parent_tree.add(@parent_node => @tree)
      @tree = @parent_tree[@parent_node]
      self
    end


    ###################################################################
    # Tree API
    ###################################################################

    #####################
    # query interface #
    #####################

    alias __getobj__ presence

    def child(node, &block)
      Absence.at(self, node)
    end

    alias [] child

    def inspect
      "Sycamore::Absence.at(#@parent_tree, #@parent_node)"
    end

    #####################
    # command interface #
    #####################

    # TODO: YARD should be informed about this method definitions.
    Tree.command_methods.each do |command_method|
      case
        when Tree.additive_command_methods.include?(command_method)

          # TODO: Should differentiate requested and created or
          #         this method should be undefined to be delegated by Delegator!
          # TODO: This method should be atomic.
          define_method command_method do |*args|
            create_presence.send(command_method, *args) # TODO: Problem: How can we hand over a possible block? With eval etc.?
            install_presence unless installed?
            presence
          end

        when Tree.destructive_command_methods.include?(command_method)

          # TODO: Should differentiate requested and created or
          #         this method should be undefined to be delegated by Delegator!
          define_method command_method do |*args|
            self
          end

        else
          fail "Unknown command method: #{command_method}"
      end
    end

  end
end
