module Sycamore

  ############################################################################
  # Tree factory function
  #
  # A convenience method for the constructor. So, instead of
  #
  #     Sycamore::Tree.new(...) { ... }
  #
  # you can write
  #
  #     Sycamore::Tree(...) { ... }
  #
  # @see For an even more convenient method, see the unqualified usage with
  #   the global {Tree} function.
  #
  def self.Tree(*args, &block)
    Sycamore::Tree.new(*args, &block)
  end


  ############################################################################
  # Tree class
  #
  # A data structure for a mapping of nodes to other {Tree}s,
  #   containing nodes with more {Tree}s ...
  #
  #
  class Tree

    ################################################################
    # CQS                                                          #
    ################################################################

    include CQS

    # @return [Array<Symbol>] all command method names of the Tree class
    def self.command_methods
      %i[add << add_node add_nodes remove_node clear]
    end

    # @return [Array<Symbol>] all query method names of the Tree class
    def self.query_methods
      %i[empty? include? nodes size]
    end



    ################################################################
    # creation                                                     #
    ################################################################

    # creates a Tree and initializes it, by {#add}ing optional initial values
    #
    # {include:file:doc/methods/initialize.md}
    def initialize(*args, &block)
      @map = Hash.new
      add(*args, &block) unless args.empty? and not block_given?
    end



    ################################################################
    # nodes and children in general                                #
    ################################################################

    #####################
    #  query interface  #
    #####################

    def empty?
      query_return @map.empty?
    end

    def include?(node, &block)
      query_return @map.include? node
    end

    def size
      query_return @map.size
    end

    #####################
    # command interface #
    #####################

    def add(nodes, &block)
      if nodes.is_a? Hash or nodes.is_a? Tree # or ... TODO: extract to #tree_like? (and an alias #structured?)
        raise NotImplementedError
      else
        add_nodes(nodes, &block)
      end
      command_return
    end

    alias << add

    def clear
      @map.clear
      command_return
    end



    ########################################
    # Nodes
    ########################################

    #####################
    #  query interface  #
    #####################

    def nodes
      query_return @map.keys
    end

    #####################
    # command interface #
    #####################

    def add_node(node, &block)
      @map[node] = nil # TODO: or Nothing? Differentiation-problem! Ruby-Falsiness-Problem! Make it configurable?
      command_return
    end

    def add_nodes(*nodes, &block)
      nodes = nodes.first if nodes.size == 1 and nodes.is_a? Enumerable
      return add_node(nodes, &block) unless nodes.is_a? Enumerable
      nodes.each do |node|
        raise ArgumentError, 'NestedNodeSet' if node.is_a? Enumerable
        add_node(node, &block)
      end
      command_return
    end

    def remove_node(node, &block)
      @map.delete(node)
      command_return
    end



    ########################################
    # Children
    ########################################

    #####################
    #  query interface  #
    #####################

    #####################
    # command interface #
    #####################



    ################################################################
    # Tree as an Enumerable                                        #
    ################################################################


    ################################################################
    # Various Ruby protocols                                       #
    ################################################################

    def freeze
      @map.freeze
      super
    end


    ##########################################
    # equality as recursive node equivalence
    ##########################################


    ##########################################
    # conversion
    ##########################################


  end
end
