module Sycamore

  ############################################################################
  #
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
  #         also included in the {README.md}? If not, add a reference to {README.md}.
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
    # If you want to provide multiple initial leaves as arguments, use Tree[].
    # (We don't support it here, since we want the possibility to receive
    # additional arguments, e.g. for options etc.)
    #
    # @param (see #add)
    #
    def initialize(*args, &block)
      @map = Hash.new
      add(*args, &block) unless args.empty? # TODO: and not block_given?
    end

    ############################################################################
    # Another convenience method for the constructor. With it, you can write
    #
    #     Sycamore::Tree[...] { ... }
    #
    # instead of the longer
    #
    #     Sycamore::Tree.new(...) { ... }
    #
    # If you want to specify a block, you must use the Sycamore.Tree() factory method.
    #
    # @return [Tree] created from the given or data, or Nothing if no given or only nil values given
    #
    def self.[](*args, &block)
      args = args.first if args.count == 1
      new(args, &block)
    end

    ############################################################################
    # Another convenience method for the constructor. With it, you can write
    #
    #     Sycamore::Tree.from(...) { ... }
    #
    # instead of
    #
    #     Sycamore::Tree.new(...) { ... }
    #
    # But it will return Nothing, if no args given.
    #
    # @return [Tree] created from the given or data, or Nothing if no given or only nil values given
    #
    def self.from(*args, &block)
      args.compact!
      return Nothing if args.empty? and not block_given?
      new(*args, &block)
    end

    ############################################################################
    # Another convenience method for the constructor. With it, you can write
    #
    #     Sycamore::Tree.from!(...) { ... }
    #
    # instead of
    #
    #     Sycamore::Tree.new(...) { ... }
    #
    # But it will raise an ArgumentError, if no args given.
    #
    # @return [Tree] created from the given or data
    # @raise ArgumentError if no args or only nil values given
    #
    def self.from!(*args, &block)
      args.compact!
      raise ArgumentError if args.empty? and not block_given?
      new(*args, &block)
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

    # @return [Boolean] false, unless this is the Nothing tree
    # @todo or Absence?
    #
    def nothing?
      query_return false
    end

    # @param [Object] elements to check for, if it is an element of this tree
    #
    # @return [Boolean] if this tree includes the given node
    #
    def include?(elements)
      query_return(
        case
          when Tree.like?(elements)
            elements.all? do |node, child|
              include?(node) and
                ( child.nil? or child.equal?(Nothing) or self.child(node).include?(child) )
            end
          when elements.is_a?(Enumerable)
            require 'set' # TODO: Remove this?!
            elements.to_set.subset?(nodes.to_set)
            # (nodes.to_set - elements.to_set).empty?
          else
            @map.include?(elements)
        end)
    end

    # alias <= include?

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
    # @param [Object, Hash, Enumerable] nodes_or_struct TODO TODOC
    #
    #
    # @return self as a proper command method (see Sycamore::CQS#command_return)
    #
    # @see #add_nodes
    #
    def add(nodes_or_struct, &block)
      if Tree.like? nodes_or_struct
        add_children(nodes_or_struct, &block)
      else
        add_nodes(nodes_or_struct, &block)
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
      return command_return if node.nil? or node.equal? Nothing
      raise NestedNodeSet if node.is_a? Enumerable
      @map[node] ||= nil
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

    def child(node, &block)
      query_return @map[node] || Nothing # TODO: use @map.fetch(node, &block)
    end

    alias [] child

    def leaf?(node, &block)
      query_return @map.include?(node) &&
                     ( (child = @map[node]).nil? || child.empty? )
    end

    def leaves?(*nodes, &block)
      node = nodes.first
      query_return case
        when nodes.empty?           then leaves?(self.nodes)
        # if we get multiple arguments, recursively delegate them as an Enumerable
        when nodes.size > 1         then leaves?(nodes)
        when Tree.like?(node)       then raise ArgumentError
        when node.is_a?(Enumerable) then node.all? { |node| leaf?(node) }
                                    else leaf?(node)
      end
    end


    #####################
    # command interface #
    #####################

    # @todo Should we really ignore nil values in general?
    #   Even if it is sometimes an intended behaviour, as in my case,
    #   it might be useful other times.
    #   But when, eg. a sentinel as an object to represent the end of a
    #   data structure, isn't possible in an unordered data structure.
    #   Until someone open issue and raises a convincing use case,
    #   leave it like this.
    #
    # TODO: This should be an atomic operation.
    def add_child(node, children, &block)
      return command_return if node.nil? or node.equal? Nothing
      return add_node(node, &block) if children.nil? or children.equal?(Nothing) or # TODO: when Absence defined: child.nothing? or child.abent?
                                      (Enumerable === children and children.empty?)
      child = @map[node] ||= Tree.new
      child << children
      command_return
    end

    # TODO: This should be an atomic operation.
    def add_children(tree, &block)
      return command_return if tree.equal? Nothing
      raise ArgumentError unless Tree.like?(tree) # TODO: Spec this!
      tree.each { |node, child| add_child(node, child) }
      command_return
    end



    ################################################################
    # Tree as an Enumerable                                        #
    ################################################################

    # include Enumerable

    # def each(&block)
    #   @map.each(&block)
    # end



    ################################################################
    # equality and equivalence                                     #
    ################################################################

=begin
    def hash
      [@map, self.class].hash
    end

    def eql?(other)
      self.hash == other.hash
      # self.class == other.class and self == other
    end

    # @todo Try to convert the other.to_tree ...
    def ==(other)
      self.hash == other.hash
      # self.class == other.class and self === other
    end


    def ===(other)
      self.include?(other) and
        if other.is_a? Tree
          raise NotImplementedError # other.include?(self)
        else
          Tree.new(other).include?(self)
        end
    end
=end


    ################################################################
    # conversion                                                   #
    ################################################################

    def to_a
      nodes
    end

    # @todo Rename this: It doesn't behave consistently according
    #   the Ruby 2 protocol, by not returning a hash consistently
    #   (when consisting of leaves only).
    #   Generalize this
    def to_h
      case
        when empty?   then {}
        when leaves?  then ( size == 1 ? nodes.first : nodes )
        else
          hash = {}
          @map.each do |node, child|
            hash[node] = child.to_h
          end
          hash
      end
    end

    def to_s
      to_h.to_s
    end

    # Temporary impl., spec this!
    def inspect
      "Sycamore::Tree(#{to_h.inspect})"
    end


    # @todo This method should be defined as a Refinement of Object, Hash, Array, Enumerable, JSON::Object etc.
    # or tree_like? (and an alias #structured?)
    def self.tree_like?(object)
      case object
        when Hash || Tree # || ...
          true
        else
          (object.respond_to? :tree_like? and object.tree_like?) # or ...
      end
    end

    class << self
      alias like? tree_like?
    end


    ################################################################
    # Various other Ruby protocols                                 #
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

  end
end
