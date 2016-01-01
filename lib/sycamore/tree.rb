module Sycamore

  ############################################################################
  #
  # A tree data structure as a recursively nested set of nodes of immutable values.
  #
  # A Sycamore tree is a set of nodes with links to their child trees,
  # consisting of the child nodes and their child trees etc.
  # The links from a node to its child tree is stored in a Hash,
  # the {@data} instance variable.
  #
  # @see {README.md} for an introduction
  #
  class Tree

    include Enumerable

    attr_reader :data
    protected :data

    ################################################################
    # CQS                                                          #
    ################################################################

    include CQS

    ADDITIVE_COMMAND_METHODS =
      %i[add << add_node add_nodes add_child add_children]

    DESTRUCTIVE_COMMAND_METHODS =
      %i[delete >> delete_node delete_nodes delete_children clear]

    COMMAND_METHODS = ADDITIVE_COMMAND_METHODS + DESTRUCTIVE_COMMAND_METHODS

    PREDICATE_METHODS =
      %i[empty? nothing? present? absent? has_key? include? include_node?
         leaf? leaves? internal? external?]

    QUERY_METHODS = PREDICATE_METHODS + %i[size nodes keys child] << :[]


    # @return [Array<Symbol>] the names of all methods, which can change the state of a Tree
    #
    def self.command_methods
      COMMAND_METHODS
    end

    # @return [Array<Symbol>] the names of all command methods, which add elements to a Tree only
    #
    def self.additive_command_methods
      ADDITIVE_COMMAND_METHODS
    end

    # @return [Array<Symbol>] the names of all command methods, which delete elements from a Tree only
    #
    def self.destructive_command_methods
      DESTRUCTIVE_COMMAND_METHODS
    end

    # @return [Array<Symbol>] the names of all methods, which side-effect-freeze return only a value
    #
    def self.query_methods
      QUERY_METHODS
    end

    # @return [Array<Symbol>] the names of all query methods, which return a boolean
    #
    def self.predicate_methods
      PREDICATE_METHODS
    end


    ########################################################################
    # construction
    ########################################################################

    # creates a new empty Tree
    #
    def initialize
      @data = Hash.new
    end

    # creates a new Tree and initializes it with the given data
    #
    # @example
    #   Tree[1]           # => 1
    #   Tree[1, 2, 3]     # => [1,2,3]
    #   Tree[1, 2, 2, 3]  # => [1,2,3]
    #   Tree[x: 1, y: 2]  # => {:x=>1, :y=>2}
    #
    # @param (see #add)
    #
    # @return [Tree] initialized with the given data
    #
    def self.with(*args)
      tree = new
      tree.add( args.size == 1 ? args.first : args ) unless args.empty?
      tree
    end

    class << self
      alias from with
      alias [] with
    end


    ######################
    # Child construction #
    ######################

    def new_child(*args)
      case
        when child_constructor.nil? then self.class.new(*args)
        when child_class            then child_class.new(*args)
        # TODO: pending Tree#clone
        # when child_prototype        then child_prototype.clone.add(*args)
        when child_generator        then child_generator.call
        else raise "invalid child constructor: #{child_constructor.inspect}"
      end
    end

    def child_constructor=(prototype_or_class)
      case prototype_or_class
        when Class then self.child_class = prototype_or_class
        # TODO: pending Tree#clone
        # when Tree  then self.child_prototype = prototype_or_class
        else raise ArgumentError, "expected a Sycamore::Tree object or subclass, but got a #{prototype_or_class}"
      end
    end

    def child_constructor
      @child_constructor
    end

    def child_class
      @child_constructor if @child_constructor.is_a? Class
    end

    def child_class=(tree_class)
      raise ArgumentError, "expected a Tree subclass, but got a #{tree_class}" unless tree_class <= Tree
      @child_constructor = tree_class
    end


    # TODO: pending Tree#clone
    # def child_prototype
    #   @child_constructor if @child_constructor.is_a? Tree
    # end
    #
    # def child_prototype=(tree)
    #   raise ArgumentError, "expected a Tree object, but got a #{tree}" unless tree.is_a? Tree
    #   @child_constructor = tree
    # end


    def child_generator
      @child_constructor if @child_constructor.is_a? Proc
    end

    def def_child_generator(&block)
      @child_constructor = block
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
      query_return @data.empty?
    end

    # @todo or Absence?
    #
    def nothing?
      query_return false
    end

    # the negation of #absent?
    def present?
      query_return true
    end

    # the negation of #present?
    def absent?
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
              include_node?(node) and ( child.nil? or child.equal?(Nothing) or
                                          self.child(node).include?(child) )
            end
          when elements.is_a?(Enumerable)
            elements.all? { |element| include_node? element } # TODO: use include_nodes?
          else
            include_node? elements
        end)
    end

    def include_node?(node)
      @data.include?(node)
    end

    alias has_key? include_node?  # Hash compatibility

    # alias <= include?


    def each(&block)
      # return enum_for(__callee__) unless block_given? # TODO spec this in
      case block.arity
        when 1 then @data.keys.each(&block)
               else @data.each(&block)
      end
      # @data.each(&block)
    end

    def each_path(with_ancestor: Path::ROOT, &block)
      return enum_for(__callee__) unless block_given?
      each do |node, child|
        if child
          child.each_path(with_ancestor: with_ancestor.branch(node), &block)
        else
          yield Path[with_ancestor, node]
        end
      end
      self
    end

    alias paths each_path

    def has_path?(*args)
      raise ArgumentError, "wrong number of arguments (0 for 1)" if args.count == 0

      if args.count == 1
        arg = args.first
        if arg.is_a? Path
          arg.in? self
        else
          Path.of(arg).in? self
        end
      else
        Path.of(*args).in? self
      end
    end

    alias path? has_path?

    # @return [Fixnum] the number of nodes in this tree
    #
    def size
      query_return @data.size
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
    def add(nodes_or_struct)
      if Tree.like? nodes_or_struct
        add_children(nodes_or_struct)
      else
        add_nodes(nodes_or_struct)
      end
      command_return
    end

    alias << add

    # The universal method to remove nodes with or without children.
    #
    # Depending on the argument, this method only delegates appropriately to one
    # of the other more specific `delete` methods.
    #
    # @param [Object, Hash, Enumerable] nodes_or_struct TODO TODOC
    #
    #
    # @return self as a proper command method (see Sycamore::CQS#command_return)
    #
    # @see #add_nodes
    #
    def delete(nodes_or_struct)
      if Tree.like? nodes_or_struct
        delete_children(nodes_or_struct)
      else
        delete_nodes(nodes_or_struct)
      end
      command_return
    end

    alias >> delete

    # deletes all nodes and their children, resulting in an empty tree
    #
    # @return self as a proper command method (see Sycamore::CQS#command_return)
    #
    def clear
      @data.clear

      command_return
    end



    ################################################################
    # Nodes API                                                    #
    ################################################################

    #####################
    #  query interface  #
    #####################

    # The set of child nodes of the parent.
    #
    # @example
    #   child = [:bar, :baz]
    #   tree = Tree[foo: child]
    #   tree.nodes        # => [:foo]
    #   tree[:foo].nodes  # => [:bar, :baz]
    #
    # @return [Array<Object>] the nodes of this tree (without their children)
    #
    def nodes
      query_return @data.keys
    end

    alias keys nodes  # Hash compatibility

    # The only child node of the parent or an Exception, if more nodes present
    #
    # @example
    #   Tree[1].node  # => 1
    #   Tree.new.node  # => nil
    #
    #   matz = Tree[birthday: DateTime.parse('1965-04-14')]
    #   matz[:birthday].node  # => #<DateTime: 1965-04-14T00:00:00+00:00 ((2438865j,0s,0n),+0s,2299161j)>
    #
    #   Tree[1,2].node  # => TypeError: no implicit conversion of node set [1, 2] into a single node
    #
    # @return [Object] the single present node or nil, if no nodes present
    # @raise [TypeError] if more than one node present
    #
    # @todo Provide support for selector and reducer functions.
    # @todo Raise a more specific Exception than TypeError.
    def node
      nodes = self.nodes
      raise TypeError, "no implicit conversion of node set #{nodes} into a single node" if
        nodes.size > 1
      query_return nodes.first
    end


    #####################
    # command interface #
    #####################

    # TODO: Make add_node, add_nodes, add_child, add_children private.
    # TODO: Extract unique content and remove the documentation, since private?
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
    def add_node(node)
      return command_return if node.nil? or node.equal? Nothing
      return add_children(node) if Tree.like? node
      raise NestedNodeSet if node.is_a? Enumerable

      @data[node] ||= nil

      command_return
    end

    # TODO: Make add_node, add_nodes, add_child, add_children private.
    # TODO: Extract unique content and remove the documentation, since private?
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
    def add_nodes(*nodes)
      nodes = nodes.first if nodes.size == 1 and nodes.is_a? Enumerable
      return add_node(nodes) unless nodes.is_a? Enumerable

      nodes.each { |node| add_node(node) }

      command_return
    end

    # removes a node with its child
    #
    # If the given node is in the {#nodes} set, it gets deleted, otherwise
    # nothing happens.
    #
    # @param [Object] node to delete
    #
    # @return self as a proper command method (see Sycamore::CQS#command_return)
    #
    def delete_node(node)
      return delete_children(node) if Tree.like? node
      raise NestedNodeSet if node.is_a? Enumerable

      @data.delete(node)

      command_return
    end

    def delete_nodes(*nodes)
      nodes = nodes.first if nodes.size == 1 and nodes.is_a? Enumerable
      return delete_node(nodes) unless nodes.is_a? Enumerable

      nodes.each { |node| delete_node(node) }

      command_return
    end

    ################################################################
    # Children API                                                 #
    ################################################################

    #####################
    #  query interface  #
    #####################

    def child(node)
      return query_return Nothing if node.nil? or node.equal? Nothing
      query_return @data[node] || Absence.at(self, node)
    end

    alias [] child


    def fetch(*node_and_default, &block)
      case node_and_default.size
        when 1 then node = node_and_default.first
          tree = @data.fetch(node, &block)
          tree.nil? ? Nothing : tree
        when 2 then node, default = *node_and_default
          if block_given?
            warn "block supersedes default value argument"
            fetch(node, &block)
          else
            @data.fetch(node, default) or Nothing
          end
        else raise ArgumentError, "wrong number of arguments (0 for 1)"
      end
    end

    # If the node has no children.
    #
    def leaf?(node)
      query_return @data.include?(node) &&
                     ( (child = @data[node]).nil? || child.empty? )
    end

    def leaves?(*nodes)
      node = nodes.first
      query_return case
        when nodes.empty?           then leaves?(self.nodes)
        # if we get multiple arguments, delegate them recursively as an Enumerable
        when nodes.size > 1         then leaves?(nodes)
        when Tree.like?(node)       then raise ArgumentError
        when node.is_a?(Enumerable) then node.all? { |node| leaf?(node) }
                                    else leaf?(node)
      end
    end

    alias flat? leaves?
    alias external? leaves?

    def internal?(*nodes)
      not external?(*nodes) and include?(nodes)
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
    def add_child(node, children)
      return command_return if node.nil? or node.equal? Nothing
      return add_node(node) if children.nil? or children.equal?(Nothing) or # TODO: when Absence defined: child.nothing? or child.abent?
                                  # Enumerable === children
                                  (Enumerable === children and children.empty?)

      child = @data[node] ||= new_child
      child << children

      command_return
    end

    # TODO: This should be an atomic operation.
    def add_children(tree)
      return command_return if tree.respond_to?(:absent?) and tree.absent?
      raise ArgumentError unless Tree.like?(tree) # TODO: Spec this!

      tree.each { |node, child| add_child(node, child) }

      command_return
    end

    # TODO: This should be an atomic operation.
    def delete_children(tree)
      return command_return if tree.respond_to?(:absent?) and tree.absent?
      raise ArgumentError unless Tree.like?(tree) # TODO: Spec this!

      tree.each do |node, child|
        next unless include? node
        this_child = self.child(node)
        this_child.delete child
        delete_node(node) if this_child.empty?
      end

      command_return
    end



    ################################################################
    # equality and equivalence                                     #
    ################################################################

    def hash
      [@data, self.class].hash
    end

    def eql?(other)
      other.instance_of?(self.class) and @data.eql?(other.data)
    end

    # TODO: What should be the semantics of #==?
    #   Currently it is the same as eql?, since Hash
    #    coerces only the values and not the keys ...
    #
    # @todo Use coercion! Like Equalizer#==.  But here or in ===?
    # @todo Try to convert the other.to_tree ... ? as a coercion? Here or in ===?
    # def ==(other)
    #   other.instance_of?(self.class) and self.@data == other.@data
    # end

    alias == eql? # temporary solution. TODO: Remove this.

    # == should be the strictest form of matching?, which gets only applied if other
    #     is Tree.like?, since these definitely aren't a node of tree.
    #     Enumerables aren't for sure? What's with a Range node?
    #     Should we support this? How? ...


=begin
    def ===(other)
      self.include?(other) and
        if other.is_a? Tree
          raise NotImplementedError # other.include?(self)
        else
          Tree.new(other).include?(self)
        end
    end
=end

    def matches?(other, comparator = :===)
      case
        when Tree.like?(other)       then matches_tree?(other, comparator)
        when other.is_a?(Enumerable) then matches_enumerable?(other, comparator)
                                     else matches_atom?(other, comparator)
      end
    end

    alias === matches?

    private def matches_atom?(other, comparator = :===)
      (self.empty? and (other.nil? or other == Nothing)) or
        (self.size == 1 and nodes.first.send(comparator, other))
    end

    private def matches_enumerable?(other, comparator = :===)
      self.size == other.size and
        self.nodes.all? { |node| other.include?(node) }
    end

    private def matches_tree?(other, comparison = :===)
      self.size == other.size and
        self.all? { |node, child|
          # TODO: Optimize this!
          if child.nil?
            other.include?(node) and
              ( other[node].nil? or other[node] == Nothing )
          else
            child.matches? other[node]
          end }
    end


    ################################################################
    # conversion                                                   #
    ################################################################

    # def to_a
    #   map { |node, child| child.nil? ? node : { node => child.to_a } }
    # end

    # @todo Rename this: It doesn't behave consistently according
    #   the Ruby 2 protocol, by not returning a hash consistently
    #   (when consisting of leaves only).
    #   Generalize this ...
    def to_h
      case
        when empty?   then {}
        when leaves?  then ( size == 1 ? nodes.first : nodes )
        else
          hash = {}
          @data.each do |node, child|
            hash[node] = child.to_h
          end
          hash
      end
    end

    def to_s
      to_h.to_s
    end

    # @return a developer-friendly representation of `self` in the usual Ruby Object#inspect style.
    #
    def inspect
      "#<Sycamore::Tree:0x#{object_id.to_s(16)}(#{to_h.inspect})>"
    end


    # @todo This method should be defined as a Refinement of Object, Hash, Array, Enumerable, JSON::Object etc.
    # or tree_like? (and an alias #structured?)
    def self.tree_like?(object)
      case object
        when Hash, Tree #, Absence ?, ... ?!
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

    # overrides {Object#freeze} by delegating it to the internal hash {@data}
    #
    # TODO: How to do proper links with YARD and markdown support?
    #
    # @see Ruby's [Object#freeze](http://ruby-doc.org/core-2.2.2/Object.html#method-i-freeze)
    # @see Ruby's {http://ruby-doc.org/core-2.2.2/Object.html#method-i-freeze Object#freeze}
    #
    def freeze
      @data.freeze
      super
    end

  end

end
