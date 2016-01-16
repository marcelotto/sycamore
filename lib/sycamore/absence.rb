require 'delegate'

module Sycamore
  class Absence < Delegator

    def initialize(parent_tree, parent_node)
      raise ArgumentError if not (parent_tree.is_a?(Tree) or
                                  parent_tree.is_a?(Absence)) or parent_node.nil?
      @parent_tree, @parent_node = parent_tree, parent_node
    end

    class << self
      alias at new
    end


    ###################################################################
    # predicates
    ###################################################################

    # @see {Tree#absent?}
    def absent?
      @tree.nil?
    end

    def nothing?
      false
    end

    # TODO: Remove this? It's currently used only in tests.
    def absent_parent?
      @parent_tree.absent?
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

    def child_of(node, &block)
      Absence.at(self, node)
    end

    alias [] child_of

    def inspect
      "Sycamore::Absence.at(#@parent_tree, #@parent_node)"
    end

    #####################
    # command interface #
    #####################

    # TODO: YARD should be informed about this method definitions.
    Tree.command_methods.each do |command_method|
      if Tree.destructive_command_methods.include?(command_method)
        define_method command_method do |*args|
          self
        end
      else
        # TODO: This method should be atomic.
        define_method command_method do |*args|
          create_presence.send(command_method, *args) # TODO: How can we hand over a possible block? With eval etc.?
          install_presence unless installed?
          presence
        end
      end
    end

  end
end
