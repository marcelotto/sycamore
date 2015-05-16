module Sycamore

  ############################################################################
  # Tree factory function
  #
  # A convenience method for the constructor. With it, you can write
  #
  #     Sycamore::Tree(...) { ... }
  #
  # instead of the longer
  #
  #     Sycamore::Tree.new(...) { ... }
  #
  # @see For an even more convenient method, see the unqualified usage with
  #   the global {::Tree()} function.
  #
  def self.Tree(*args, &block)
    Sycamore::Tree.new(*args, &block)
  end


  ############################################################################
  #
  # A data structure for a mapping of nodes to other {Tree}s, containing nodes
  # with more {Tree}s as children and so on recursively.
  #
  # TODO: include the usage demonstrations from the dedicated Markdown documents,
  #         also included in the {README.md}
  #
  # = Usage =
  #
  # == Creation
  #
  # == Nodes
  #
  # == Children
  #
  # == Absence and the Nothing tree
  #
  # == Equivalence
  #
  # == Traversal
  #
  # == Enumerable
  #
  class Tree

    ################################################################
    # CQS                                                          #
    ################################################################

    include CQS

    # @return [Array<Symbol>] all command method names of this class
    #
    def self.command_methods
      %i[add << add_node add_nodes remove_node clear]
    end

    # @return [Array<Symbol>] all query method names of this class
    #
    def self.query_methods
      %i[empty? include? nodes size]
    end



    ################################################################
    # creation                                                     #
    ################################################################

    # creates a Tree and initializes it, by {#add}ing optional initial nodes
    #
    # When arguments and/or a block given, it delegates them to {#add}.
    #
    # @param (see #add)
    #
    def initialize(*args, &block)
      @map = Hash.new
      add(*args, &block) unless args.empty? and not block_given?
    end



    ################################################################
    # general nodes and children API                               #
    ################################################################

    #####################
    #  query interface  #
    #####################

    # @return [Boolean] if this tree is empty, meaning including no nodes
    #
    def empty?
      query_return @map.empty?
    end

    # @param [Object] node to check for, if it is an element of this tree
    #
    # @return [Boolean] if this tree includes the given node
    #
    def include?(node)
      query_return @map.include?(node)
    end

    # @return [Fixnum] the number of nodes in this tree
    #
    def size
      query_return @map.size
    end


    #####################
    # command interface #
    #####################

    # The universal method to add nodes with or without children.
    #
    # Depending on the argument, this method only delegates appropriately to one
    # of the other more specific `add` methods.
    #
    # @param [Object, Hash, Enumerable] nodes TODO TODOC
    #
    #
    # @return self as a proper command method (see Sycamore::CQS#command_return)
    #
    # @see #add_nodes
    #
    def add(nodes, &block)
      if nodes.is_a? Hash or nodes.is_a? Tree # or ... TODO: extract to #tree_like? (and an alias #structured?)
        raise NotImplementedError
      else
        add_nodes(nodes, &block)
      end
      command_return
    end

    alias << add

    # removes all nodes and their children, resulting in an empty tree
    #
    # @return self as a proper command method (see Sycamore::CQS#command_return)
    #
    def clear
      @map.clear
      command_return
    end



    ################################################################
    # Nodes API                                                    #
    ################################################################

    #####################
    #  query interface  #
    #####################

    # @return [Array<Object>] the nodes of this tree (without their children)
    #
    def nodes
      query_return @map.keys
    end


    #####################
    # command interface #
    #####################

    # adds a single leaf
    #
    # @todo https://www.pivotaltracker.com/story/show/94733228
    #   reasons for the NestedNodeSet exception
    #
    # @todo https://www.pivotaltracker.com/story/show/94733114
    #   What should we use as the default value for the hash entry of a leaf?
    #
    # @param [Object] node to add
    #
    #   If node is an Enumerable, an {NestedNodeSet} exception is raised
    #
    # @return self as a proper command method (see Sycamore::CQS#command_return)
    #
    # @see #add, #add_nodes
    #
    def add_node(node, &block)
      raise NestedNodeSet if node.is_a? Enumerable
      @map[node] = nil
      command_return
    end

    # adds multiples leaves
    #
    # It can handle the leaves either given as arguments:
    #
    #     tree.add_nodes(1, 2, 3)
    #
    # or as a single Enumerable:
    #
    #     tree.add_nodes [1, 2, 3]
    #
    # It delegates every single leaf to {$add_node}. Although this isn't the
    # fastest way, adding the nodes directly to the hash would be a premature
    # optimization and is deferred until the API has settled.
    #
    # As it delegates to {add_node}, if one the given values it itself an Enumerable,
    # a {NestedNodeException} gets raised.
    #
    # @param [Object] nodes to add
    #
    #   If the nodes Enumerable contains other Enumerables, an {NestedNodeSet} exception is raised
    #
    # @return self as a proper command method (see Sycamore::CQS#command_return)
    #
    # @raise {NestedNodeSet}
    #
    # @see #add, #add_node
    #
    def add_nodes(*nodes, &block)
      nodes = nodes.first if nodes.size == 1 and nodes.is_a? Enumerable
      return add_node(nodes, &block) unless nodes.is_a? Enumerable
      nodes.each { |node| add_node(node, &block) }
      command_return
    end

    # removes a node with its child
    #
    # If the given node is in the {#nodes} set, it gets removed, otherwise
    # nothing happens.
    #
    # @param [Object] node to remove
    #
    # @return self as a proper command method (see Sycamore::CQS#command_return)
    #
    def remove_node(node, &block)
      @map.delete(node)
      command_return
    end



    ################################################################
    # Children API                                                 #
    ################################################################

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

    # overrides {Object#freeze} by delegating it to the internal hash {@map}
    #
    # TODO: How to do proper links with YARD and markdown support?
    #
    # @see Ruby's [Object#freeze](http://ruby-doc.org/core-2.2.2/Object.html#method-i-freeze)
    # @see Ruby's {http://ruby-doc.org/core-2.2.2/Object.html#method-i-freeze Object#freeze}
    #
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
