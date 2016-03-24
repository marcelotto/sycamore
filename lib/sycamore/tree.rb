module Sycamore

  ##
  # A tree data structure as a recursively nested set of {#nodes nodes} of immutable values.
  #
  # See {file:README.md} for a general introduction.
  #
  class Tree

    include Enumerable

    # the internal hash representation of this tree
    attr_reader :data
    protected :data

    ########################################################################
    # @group CQS reflection
    ########################################################################

    # the names of all command methods, which add elements to a Tree
    ADDITIVE_COMMAND_METHODS = %i[add << replace add_node_with_empty_child] << :[]=

    # the names of all command methods, which delete elements from a Tree
    DESTRUCTIVE_COMMAND_METHODS = %i[delete >> clear compact replace] << :[]=

    # the names of all additive command methods, which only add elements from a Tree
    PURE_ADDITIVE_COMMAND_METHODS = ADDITIVE_COMMAND_METHODS - DESTRUCTIVE_COMMAND_METHODS

    # the names of all destructive command methods, which only delete elements from a Tree
    PURE_DESTRUCTIVE_COMMAND_METHODS = DESTRUCTIVE_COMMAND_METHODS - ADDITIVE_COMMAND_METHODS

    # the names of all methods, which change the state of a Tree
    COMMAND_METHODS = ADDITIVE_COMMAND_METHODS + DESTRUCTIVE_COMMAND_METHODS +
      %i[freeze]

    # the names of all query methods, which return a boolean
    PREDICATE_METHODS =
      %i[nothing? absent? existent? present? blank? empty?
         include? include_node? member? key? has_key? include_path? path? >= > < <=
         leaf? leaves? internal? external? flat? nested?
         sleaf? sleaves? strict_leaf? strict_leaves?
         eql? matches? === ==]

    # the names of all methods, which side-effect-freeze return only a value
    QUERY_METHODS = PREDICATE_METHODS +
      %i[new_child dup hash to_native_object to_h to_s inspect
         node nodes keys child_of child_at dig fetch
         size total_size tsize height
         each each_path paths each_node each_key each_pair] << :[]

    %i[COMMAND_METHODS QUERY_METHODS PREDICATE_METHODS
       ADDITIVE_COMMAND_METHODS DESTRUCTIVE_COMMAND_METHODS
       PURE_ADDITIVE_COMMAND_METHODS PURE_DESTRUCTIVE_COMMAND_METHODS]
      .each do |method_set|
        define_singleton_method(method_set.downcase) { const_get method_set }
      end

    ########################################################################
    # @group Construction
    ########################################################################

    ##
    # Creates a new empty Tree.
    #
    def initialize
      @data = Hash.new
    end

    ##
    # Creates a new Tree and initializes it with the given data.
    #
    # @param (see #add)
    # @return [Tree]
    #
    # @example
    #   Tree[1]
    #   Tree[1, 2, 3]
    #   Tree[1, 2, 2, 3]  # duplicates are ignored, so this results in the same tree as the previous
    #   Tree[x: 1, y: 2]
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

    ##
    # Creates a new tree meant to be used as a child.
    #
    # This method is used for instantiation of child trees. When you want to a
    # tree with different types child trees, maybe depending on the parent node,
    # you can subclass {Sycamore::Tree} and override this method to your needs.
    # By default it creates trees of the same type as this tree.
    #
    # @param parent_node [Object] of the child tree to be created
    # @return [Tree]
    #
    # @api private
    #
    def new_child(parent_node, *args)
      self.class.new(*args)
    end


    ########################################################################
    # @group Absence and Nothing predicates
    ########################################################################

    ##
    # Checks if this is the {Nothing} tree.
    #
    # @return [Boolean]
    #
    def nothing?
      false
    end

    ##
    # Checks if this is an unresolved {Absence} or {Nothing}.
    #
    # @return [Boolean]
    #
    def absent?
      false
    end

    ##
    # Checks if this is not an {Absence} or {Nothing}.
    #
    # @return [Boolean]
    #
    def existent?
      not absent?
    end

    ##
    # Checks if this is not {#blank? blank}, i.e. {#empty? empty}.
    #
    # @note This is not the negation of {#absent?}, since this would result in a
    #   different behaviour than {http://api.rubyonrails.org/classes/Object.html#method-i-present-3F ActiveSupports present?}
    #   method. For the negation of {#absent?}, see {#existent?}.
    #
    # @return [Boolean]
    #
    def present?
      not blank?
    end


    ########################################################################
    # @group Element access
    ########################################################################

    #####################
    #  command methods  #
    #####################

    ##
    # Adds nodes or a tree structure to this tree.
    #
    # Note, since a {Sycamore::Tree} can't contain +nil+ values, they are
    # silently ignored.
    #
    # @overload add(node)
    #   adds a single node
    #   @param node [Object]
    #
    # @overload add(node_collection)
    #   adds multiple nodes
    #   @param node_collection [Enumerable]
    #
    # @overload add(tree_structure)
    #   adds a tree structure of nodes
    #   @param tree_structure [Hash, Tree]
    #
    # @return +self+ as a proper command method
    #
    # @raise [InvalidNode] when given a nested node set
    #
    # @example
    #   tree = Tree.new
    #   tree.add :foo
    #   tree.add [:bar, :baz]
    #   tree.add [:node, [:nested, :values]]  # => raise Sycamore::InvalidNode, "[:nested, :values] is not a valid tree node"
    #   tree.add foo: 1, bar: {baz: 2}
    #   tree.add foo: [:node, [:nested, :values]]  # => raise Sycamore::InvalidNode, "[:nested, :values] is not a valid tree node"
    #
    #   tree = Tree.new
    #   tree[:foo][:bar] << :baz
    #   tree[:foo] << { bar: 1, qux: 2 }
    #   tree.to_h  # => {:foo=>{:bar=>[:baz, 1], :qux=>2}}
    #
    # @todo support Paths
    #
    def add(nodes_or_tree)
      case
        when Tree.like?(nodes_or_tree)       then add_tree(nodes_or_tree)
        when nodes_or_tree.is_a?(Enumerable) then add_nodes(nodes_or_tree)
                                             else add_node(nodes_or_tree)
      end

      self
    end

    alias << add

    ##
    # Adds a node with an empty child to this tree.
    #
    # @return +self+ as a proper command method
    #
    # @raise [InvalidNode]
    #
    # @api private
    #
    def add_node_with_empty_child(node)
      raise InvalidNode, "#{node} is not a valid tree node" if node.nil? or node.is_a? Enumerable

      if @data.fetch(node, Nothing).nothing?
        @data[node] = new_child(node)
      end

      self
    end

    private def add_node(node)
      return self if Nothing.like? node
      return add_tree(node) if Tree.like? node
      raise InvalidNode, "#{node} is not a valid tree node" if node.is_a? Enumerable

      @data[node] ||= Nothing

      self
    end

    private def add_nodes(nodes)
      nodes.each { |node| add_node(node) }

      self
    end

    private def add_child(node, children)
      return self if node.nil?
      return add_node(node) if Nothing.like?(children)

      add_node_with_empty_child(node)
      @data[node] << children

      self
    end

    private def add_tree(tree)
      tree.each { |node, child| add_child(node, child) }

      self
    end

    ##
    # Remove nodes or a tree structure from this tree.
    #
    # If a given node is in the {#nodes} set, it gets deleted, otherwise it is
    # silently ignored.
    #
    # @overload delete(node)
    #   deletes a single node
    #   @param node [Object]
    #
    # @overload delete(node_collection)
    #   deletes multiple nodes
    #   @param node_collection [Enumerable]
    #
    # @overload delete(tree_structure)
    #   deletes a tree structure of nodes
    #   @param tree_structure [Hash, Tree]
    #
    # @return +self+ as a proper command method
    #
    # @raise [InvalidNode] when given a nested node set
    #
    # @example
    #   tree = Tree[ "a" => 100, "b" => 200, "c" => 300, "d" => {foo: [:bar, :baz]} ]
    #   tree.delete "a"
    #   tree.to_h  # => {"b" => 200, "c" => 300, "d" => {foo: [:bar, :baz]}}
    #   tree.delete ["a", "b", "c"]
    #   tree.to_h  # => {"d" => {foo: [:bar, :baz]}}
    #   tree.delete "d" => {foo: :bar}
    #   tree.to_h  # => {"d" => {foo: :baz}}
    #   tree.delete "d" => {foo: :baz}
    #   tree.to_h  # => {}
    #
    # @todo differentiate a greedy and a non-greedy variant
    # @todo support Paths
    #
    def delete(nodes_or_tree)
      case
        when Tree.like?(nodes_or_tree)       then delete_tree(nodes_or_tree)
        when nodes_or_tree.is_a?(Enumerable) then delete_nodes(nodes_or_tree)
                                             else delete_node(nodes_or_tree)
      end

      self
    end

    alias >> delete

    private def delete_node(node)
      return delete_tree(node) if Tree.like? node
      raise InvalidNode, "#{node} is not a valid tree node" if node.is_a? Enumerable

      @data.delete(node)

      self
    end

    private def delete_nodes(nodes)
      nodes.each { |node| delete_node(node) }

      self
    end

    private def delete_tree(tree)
      tree.each do |node, child|
        raise InvalidNode, "#{node} is not a valid tree node" if node.is_a? Enumerable
        next unless include? node
        if Nothing.like?(child) or (child.respond_to?(:empty?) and child.empty?)
          delete_node node
        else
          child_of(node).tap do |this_child|
            this_child.delete child
            delete_node(node) if this_child.empty?
          end
        end
      end

      self
    end

    ##
    # Replaces the contents of this tree.
    #
    # Note, since a {Sycamore::Tree} can't contain +nil+ values, they are
    # silently ignored.
    #
    # @overload replace(node)
    #   Replaces the contents of this tree with a single node.
    #   @param node [Object]
    #
    # @overload replace(node_collection)
    #   Replaces the contents of this tree with multiple nodes.
    #   @param node_collection [Enumerable]
    #
    # @overload replace(tree_structure)
    #   Replaces the contents of this tree with a tree structure of nodes.
    #   @param tree_structure [Hash, Tree]
    #
    # @return +self+ as a proper command method
    #
    # @raise [InvalidNode] when given a nested node set
    #
    # @example
    #   tree = Tree[ "a" => 100, "b" => 200, "d" => {foo: [:bar, :baz]} ]
    #   tree.replace(new: :content)
    #   tree.to_h  # => {new: :content}
    #
    def replace(nodes_or_tree)
      clear.add(nodes_or_tree)
    end

    ##
    # Replaces the contents of a child tree.
    #
    # As this is just a call of {#replace} on the child tree, you can assign
    # content to not existing child trees. Just like {#child_at} you can
    # reference a deeper node with a path of nodes.
    #
    # Note that even if you assign a {Sycamore::Tree} directly the given tree
    # will not become part of this tree by reference.
    #
    # Since a {Sycamore::Tree} can't contain +nil+ values, they are
    # silently ignored.
    #
    # @overload []=(*path, node)
    #   Replaces the contents of the child at the given path with a single node.
    #   @param path [Array<Object>, Sycamore::Path] a path as a sequence of nodes or a {Path} object
    #   @param node [Object]
    #
    # @overload []=(*path, node_collection)
    #   Replaces the contents of the child at the given path with multiple nodes.
    #   @param path [Array<Object>, Sycamore::Path] a path as a sequence of nodes or a {Path} object
    #   @param node_collection [Enumerable]
    #
    # @overload []=(*path, tree_structure)
    #   Replaces the contents of the child at the given path with a tree structure of nodes.
    #   @param path [Array<Object>, Sycamore::Path] a path as a sequence of nodes or a {Path} object
    #   @param tree_structure [Hash, Tree]
    #
    # @return the rvalue as for any Ruby assignment
    #
    # @raise [InvalidNode] when given a nested node set
    #
    # @example
    #   tree = Tree[:foo]
    #   tree[:foo] = :bar
    #   tree.to_h  # => {:foo => :bar}
    #   tree[:foo] = :baz
    #   tree.to_h  # => {:foo => :baz}
    #   tree[1][2][3] = 4
    #   tree[1, 2, 3] = 4
    #   tree.to_h  # => {:foo => :baz, 1 => {2 => {3 => 4}}}
    #   tree[1] = tree[:foo]
    #   tree.to_h  # => {:foo => :baz, 1 => :baz}
    #   tree[:foo] << :bar
    #   tree.to_h  # => {:foo => [:baz, :bar], 1 => :baz}
    #
    def []=(*args)
      path, nodes_or_tree = args[0..-2], args[-1]
      raise ArgumentError, 'wrong number of arguments (given 1, expected 2)' if path.empty?

      child_at(*path).replace(nodes_or_tree)
    end

    ##
    # Deletes all nodes and their children.
    #
    # @return +self+ as a proper command method
    #
    # @example
    #   tree = Tree[1, 2, 3]
    #   tree.size  # => 3
    #   tree.clear
    #   tree.size  # => 0
    #
    def clear
      @data.clear

      self
    end

    ##
    # Deletes all empty child trees recursively.
    #
    # @return +self+ as a proper command method
    #
    # @example
    #   tree = Tree[foo: {bar: :baz}]
    #   tree[:foo, :bar].clear
    #   tree.to_h  # => {foo: {bar: []}}
    #   tree.compact
    #   tree.to_h  # => {foo: :bar}
    #
    def compact
      @data.each do |node, child| case
          when child.nothing? then next
          when child.empty?   then @data[node] = Nothing
          else child.compact
        end
      end

      self
    end


    #####################
    #   query methods   #
    #####################

    ##
    # The nodes of this tree (without their children).
    #
    # @return [Array<Object>]
    #
    # @example
    #   tree = Tree[foo: [:bar, :baz]]
    #   tree.nodes        # => [:foo]
    #   tree[:foo].nodes  # => [:bar, :baz]
    #
    def nodes
      @data.keys
    end

    alias keys nodes  # Hash compatibility


    ##
    # The only node of this tree or an exception, if more {#nodes nodes} present.
    #
    # @return [Object, nil] the single present node or +nil+, if no nodes present
    #
    # @raise [NonUniqueNodeSet] if more than one node present
    #
    # @example
    #   tree = Tree[foo: 1, bar: [2,3]]
    #   tree[:foo].node  # => 1
    #   tree[:baz].node  # => nil
    #   tree[:bar].node  # => raise Sycamore::NonUniqueNodeSet, "multiple nodes present: [2, 3]"
    #
    def node
      nodes = self.nodes
      raise NonUniqueNodeSet, "multiple nodes present: #{nodes}" if nodes.size > 1

      nodes.first
    end

    ##
    # The child tree of a node.
    #
    # When a child to the given node is not a present, an {Absence} object
    # representing the missing tree is returned.
    #
    # @param node [Object]
    # @return [Tree, Absence] the child tree of a node if present, otherwise an {Absence}
    #
    # @raise [InvalidNode] when given an +Enumerable+ or +nil+
    #
    # @example
    #   tree = Tree[foo: 1]
    #   tree.child_of(:foo).inspect  # "#<Sycamore::Tree:0x3fea48dd0e74 {1=>nil}>"
    #   tree.child_of(:bar).inspect  # "absent child of node :bar in #<Sycamore::Tree:0x3fea48dd0f3c {:foo=>1}>"
    #
    # @todo Should we differentiate the case of a leaf and a not present node? How?
    #
    def child_of(node)
      raise InvalidNode, "#{node} is not a valid tree node" if node.nil? or node.is_a? Enumerable

      Nothing.like?(child = @data[node]) ? Absence.at(self, node) : child
    end

    ##
    # The child tree of a node at a path.
    #
    # When a child to the given node is not a present, an {Absence} object
    # representing the missing tree is returned.
    #
    # @overload child_at(*nodes)
    #   @param nodes [Array<Object>] a path as a sequence of nodes
    #
    # @overload child_at(path)
    #   @param path [Path] a path as a {Sycamore::Path} object
    #
    # @return [Tree, Absence] the child tree at the given path if present, otherwise an {Absence}
    #
    # @example
    #   tree = Tree[foo: {bar: 1}]
    #   tree[:foo].inspect        # "#<Sycamore::Tree:0x3fea48e24f10 {:bar=>1}>"
    #   tree[:foo, :bar].inspect  # "#<Sycamore::Tree:0x3fea48e24ed4 {1=>nil}>"
    #   tree[:foo, :baz].inspect  # "absent child of node :baz in #<Sycamore::Tree:0x3fea48e24f10 {:bar=>1}>"
    #
    # @todo Should we differentiate the case of a leaf and a not present node? How?
    #
    def child_at(*path)
      first = path.first
      case path.length
        when 0
          raise ArgumentError, 'wrong number of arguments (given 0, expected 1+)'
        when 1
          if first.is_a? Enumerable
            child_at(*first)
          else
            child_of(*path)
          end
        else
          child_of(first).child_at(*path[1..-1])
      end
    end

    alias [] child_at
    alias dig child_at  # Hash compatibility

    ##
    # The child tree of a node.
    #
    # If the node can’t be found or has no child tree, there are several options:
    # - With no other arguments, it will raise a +KeyError+ exception when the
    #   node can’t be found or a {ChildError} exception (which is a subclass of
    #   +KeyError+) when the node has no child tree
    # - if +default+ is given, then that will be returned;
    # - if the optional code block is specified, then that will be run and its result returned.
    #
    # @param node [Object]
    # @param default [Object] optional
    # @return [Tree, default]
    #
    # @raise [InvalidNode] when given an +Enumerable+ or +nil+ as node
    # @raise [KeyError] when the given +node+ can't be found
    # @raise [ChildError] when no child for the given +node+ present
    #
    # @example
    #   tree = Tree[x: 1, y: nil]
    #   tree.fetch(:x)               # #<Sycamore::Tree:0x3fc798a63854(1)>
    #   tree.fetch(:y)               # => raise Sycamore::ChildError, "node y has no child tree"
    #   tree.fetch(:z)               # => raise KeyError, "key not found: :z"
    #   tree.fetch(:z, :default)     # => :default
    #   tree.fetch(:y, :default)     # => :default
    #   tree.fetch(:z) { :default }  # => :default
    #
    # @todo Should we differentiate the case of a leaf and a not present node? How?
    #
    def fetch(node, *default, &block)
      raise InvalidNode, "#{node} is not a valid tree node" if node.nil? or node.is_a? Enumerable

      child = @data.fetch(node, *default, &block)
      if child.equal? Nothing
        child = case
          when block_given?    then yield
          when !default.empty? then default.first
          else raise ChildError, "node #{node} has no child tree"
        end
      end

      child
    end

    ##
    # Iterates over all {#nodes nodes} of this tree.
    #
    # Note that does not include the nodes of the child trees.
    #
    # @overload each_node
    #   Iterates over all {#nodes nodes} of this tree.
    #   @yield [Object] each node
    #   @return [Tree]
    #
    # @overload each_node
    #   Returns an enumerator over all {#nodes nodes} of this tree.
    #   @return [Enumerator<Object>]
    #
    # @example
    #   tree = Tree[ "a" => 100, "b" => 200 ]
    #   tree.each_node {|node| puts node }
    #
    #   > a
    #   > b
    #
    def each_node(&block)
      return enum_for(__callee__) unless block_given?

      @data.each_key(&block)

      self
    end

    alias each_key each_node  # Hash compatibility

    ##
    # Iterates over all {#nodes nodes} and their child trees.
    #
    # @overload each_pair
    #   Iterates over all {#nodes nodes} and their child trees.
    #   @yield [Object, Tree] each node-child pair
    #   @return [Tree] +self+
    #
    # @overload each_pair
    #   Returns an enumerator over all {#nodes nodes} and their child trees.
    #   @return [Enumerator<Array(Object, Tree)>]
    #
    # @example
    #   tree = Tree[ "a" => 100, "b" => nil ]
    #   tree.each_pair {|node, child| puts "#{node} => #{child}" }
    #
    #   > a => #<Tree[ 100 ]>
    #   > b => #<Tree: Nothing>
    #
    def each_pair(&block)
      return enum_for(__callee__) unless block_given?

      @data.each_pair(&block)

      self
    end

    alias each each_pair

    ##
    # Iterates over the {Path paths} to all leaves of this tree.
    #
    # @overload each_path
    #   Iterates over the {Path paths} to all leaves of this tree.
    #   @yieldparam [Path] path
    #   @return [Tree] +self+
    #
    # @overload each_path
    #   Returns an enumerator over the {Path paths} to all leaves of this tree.
    #   @return [Enumerator<Path>]
    #
    # @example
    #   tree = Tree[ "a" => 100, "b" => { foo: [:bar, :baz] } ]
    #   tree.each_path { |path| puts path }
    #
    #   > #<Path: /a/100>
    #   > #<Path: /b/foo/bar>
    #   > #<Path: /b/foo/baz>
    #
    def each_path(with_ancestor: Path::ROOT, &block)
      return enum_for(__callee__) unless block_given?

      each do |node, child|
        if child.empty?
          yield Path[with_ancestor, node]
        else
          child.each_path(with_ancestor: with_ancestor.branch(node), &block)
        end
      end

      self
    end

    alias paths each_path

    ##
    # Checks if a path of nodes exists in this tree.
    #
    # @param args [Array<Object>, Path] a splat of nodes, an array of nodes or a {Path} object
    # @return [Boolean]
    #
    # @example
    #   tree = Tree[ "a" => 100, "b" => 200, "c" => { foo: [:bar, :baz] } ]
    #   tree.include_path? "a", 200  # => false
    #   tree.include_path? "c", :foo, :bar  # => true
    #   tree.include_path? ["c", :foo, :bar]  # => true
    #   tree.include_path? Sycamore::Path["c", :foo, :bar]  # => true
    #
    def include_path?(*args)
      raise ArgumentError, 'wrong number of arguments (given 0, expected 1+)' if args.count == 0
      first = args.first
      if first.is_a? Enumerable
        return include_path?(*first) if args.count == 1
        raise InvalidNode, "#{first} is not a valid tree node"
      end

      if args.count == 1
        include? first
      else
        include?(first) and child_of(first).include_path?(args[1..-1])
      end
    end

    alias path? include_path?

    ##
    # Checks if a node exists in the {#nodes nodes} set of this tree.
    #
    # @param node [Object]
    # @return [Boolean]
    #
    # @example
    #  Tree[1,2,3].include_node? 3   # => true
    #  Tree[1 => 2].include_node? 2  # => false
    #
    def include_node?(node)
      @data.include?(node)
    end

    alias member?  include_node?  # Hash compatibility
    alias has_key? include_node?  # Hash compatibility
    alias key?     include_node?  # Hash compatibility

    ##
    # Checks if some nodes or a full tree-like structure is included in this tree.
    #
    # @param elements [Object, Array, Tree, Hash]
    # @return [Boolean]
    #
    # @example
    #   tree = Tree[ "a" => 100, "b" => 200, "c" => { foo: [:bar, :baz] } ]
    #   tree.include?("a")                 # => true
    #   tree.include?(:foo)                # => false
    #   tree.include?(["a", "b"])          # => true
    #   tree.include?("c" => {foo: :bar})  # => true
    #   tree.include?("a", "b" => 200)     # => true
    #
    def include?(*elements)
      raise ArgumentError, 'wrong number of arguments (given 0, expected 1+)' if
        elements.size == 0
      return elements.all? { |element| include? element } if
        elements.size > 1

      elements = elements.first
      case
        when Tree.like?(elements)
          elements.all? do |node, child|
            include_node?(node) and ( child.nil? or child.equal?(Nothing) or
                                        self.child_of(node).include?(child) )
          end
        when elements.is_a?(Path)
          include_path? elements
        when elements.is_a?(Enumerable)
          elements.all? { |element| include_node? element }
        else
          include_node? elements
      end
    end

    ##
    # The number of {#nodes nodes} in this tree.
    #
    # Note, this does not count the nodes in the child trees.
    #
    # @return [Fixnum]
    #
    # @example
    #   tree = Tree[ "d" => 100, "a" => 200, "v" => 300, "e" => [400, 500] ]
    #   tree.size  # => 4
    #   tree.delete("a")
    #   tree.size  # => 3
    #   tree["e"].size  # => 2
    #
    def size
      @data.size
    end

    ##
    # The number of {#nodes nodes} in this tree and all of their children.
    #
    # @return [Fixnum]
    #
    # @example
    #   tree = Tree[ "d" => 100, "a" => 200, "v" => 300, "e" => [400, 500] ]
    #   tree.total_size  # => 9
    #   tree.delete("a")
    #   tree.total_size  # => 7
    #   tree["e"].total_size  # => 2
    #
    def total_size
      total = size
      @data.each { |_, child| total += child.total_size }
      total
    end

    alias tsize total_size

    ##
    # The length of the longest path of this tree.
    #
    # @return [Fixnum]
    #
    # @example
    #   tree = Tree[a: 1, b: {2 => 3}]
    #   tree.height  # => 3
    #
    def height
      return 0 if empty?
      paths.map(&:length).max
    end

    ##
    # Checks if this tree is empty.
    #
    # @return [Boolean]
    #
    # @example
    #   Tree.new.empty?    # => true
    #   Tree[a: 1].empty?  # => false
    #
    def empty?
      @data.empty?
    end

    alias blank? empty?

    ##
    # Checks if the given node has no children.
    #
    # @param node [Object]
    # @return [Boolean]
    #
    # @example
    #   tree = Tree[x: 1, y: [], z: nil]
    #   tree.leaf?(:x)  # => false
    #   tree.leaf?(:y)  # => true
    #   tree.leaf?(:z)  # => true
    #
    def leaf?(node)
      include_node?(node) && child_of(node).empty?
    end

    ##
    # Checks if the given node has no children, even not an empty child tree.
    #
    # @param node [Object]
    # @return [Boolean]
    #
    # @example
    #   tree = Tree[x: 1, y: [], z: nil]
    #   tree.strict_leaf?(:x)  # => false
    #   tree.strict_leaf?(:y)  # => false
    #   tree.strict_leaf?(:z)  # => true
    #
    def strict_leaf?(node)
      include_node?(node) && child_of(node).absent?
    end

    alias sleaf? strict_leaf?

    ##
    # Checks if all given nodes or that of the tree have no children, even not an empty child tree.
    #
    # @overload strict_leaves?()
    #   Returns if all {#nodes} of this tree have no children, even not an empty child tree.
    #   @return [Boolean]
    #
    # @overload strict_leaves?(*nodes)
    #   Checks if all of the given nodes have no children, even not an empty child tree.
    #   @param nodes [Array<Object>] splat of nodes
    #   @return [Boolean]
    #
    # @example
    #   Tree[1,2,3].strict_leaves?  # => true
    #   tree = Tree[a: :foo, b: :bar, c: []]
    #   tree.strict_leaves?          # => false
    #   tree.strict_leaves?(:x, :y)  # => false
    #   tree.strict_leaves?(:y, :z)  # => false
    #
    def strict_leaves?(*nodes)
      nodes = self.nodes if nodes.empty?

      nodes.all? { |node| strict_leaf?(node) }
    end

    alias sleaves? strict_leaves?

    ##
    # Checks if all given nodes or that of the tree have no children.
    #
    # @overload external?
    #   Checks if all {#nodes} of this tree have no children.
    #   @return [Boolean]
    #
    # @overload external?(*nodes)
    #   Checks if all of the given nodes have no children.
    #   @param nodes [Array<Object>] splat of nodes
    #   @return [Boolean]
    #
    # @example
    #   Tree[1,2,3].leaves?  # => true
    #   tree = Tree[x: 1, y: [], z: nil]
    #   tree.leaves?          # => false
    #   tree.leaves?(:x, :y)  # => false
    #   tree.leaves?(:y, :z)  # => true
    #
    def external?(*nodes)
      nodes = self.nodes if nodes.empty?

      nodes.all? { |node| leaf?(node) }
    end

    alias leaves? external?
    alias flat? external?

    ##
    # Checks if all given nodes or that of the tree have children.
    #
    # @overload internal?
    #   Checks if all {#nodes} of this tree have children.
    #   @return [Boolean]
    #
    # @overload internal?(*nodes)
    #   Checks if all of the given nodes have children.
    #   @param nodes [Array<Object>] splat of nodes
    #   @return [Boolean]
    #
    # @example
    #   Tree[x: 1, y: 2].internal?  # => true
    #   tree = Tree[x: 1, y: [], z: nil]
    #   tree.internal?          # => false
    #   tree.internal?(:x, :y)  # => false
    #   tree.internal?(:y, :z)  # => false
    #   tree.internal?(:x)      # => true
    #
    # @todo Does it make sense to support the no arguments variant here and with this semantics?
    #   One would expect it to be the negation of #external? without arguments.
    #
    def internal?(*nodes)
      return false if self.empty?
      nodes = self.nodes if nodes.empty?

      nodes.all? { |node| not leaf?(node) and include_node?(node) }
    end

    alias nested? internal?


    ########################################################################
    # @group Comparison
    ########################################################################

    ##
    # A hash code of this tree.
    #
    # @return [Fixnum]
    #
    def hash
      @data.hash ^ self.class.hash
    end

    ##
    # Checks if this tree has the same content as another tree.
    #
    # @param other [Object]
    # @return [Boolean]
    #
    # @example
    #   tree1 = Tree[a: 1, b: 2]
    #   tree2 = Tree[a: 1, b: 2, c: 3]
    #   tree3 = Tree[b: 2, a: 1]
    #   tree4 = Tree[a: 1, b: {2 => []}]
    #   tree1.eql? tree2  # => false
    #   tree1.eql? tree3  # => true
    #   tree1.eql? tree4  # => false
    #
    def eql?(other)
      (other.instance_of?(self.class) and @data.eql?(other.data)) or
        (other.instance_of?(Absence) and other.eql?(self))
    end

    ##
    # Checks if this tree has the same content as another tree, but ignores empty child trees.
    #
    # @param other [Object]
    # @return [Boolean]
    #
    # @example
    #   tree1 = Tree[a: 1, b: 2]
    #   tree2 = Tree[a: 1, b: 2, c: 3]
    #   tree3 = Tree[b: 2, a: 1]
    #   tree4 = Tree[a: 1, b: {2 => []}]
    #   tree1 == tree2  # => false
    #   tree1 == tree3  # => true
    #   tree1 == tree4  # => true
    #
    def ==(other)
      (other.instance_of?(self.class) and size == other.size and
        all? { |node, child| other.include?(node) and other[node] == child }) or
        ((other.equal?(Nothing) or other.instance_of?(Absence)) and
          other == self)
    end

    ##
    # Checks if this tree is a subtree of another tree.
    #
    # @param other [Object]
    # @return [Boolean]
    #
    # @example
    #   tree1 = Tree[a: 1, b: 2]
    #   tree2 = Tree[a: 1, b: 2, c: 3]
    #   tree1 < tree2  # => true
    #   tree2 < tree1  # => false
    #   tree1 < tree1  # => false
    #
    def <(other)
      (other.is_a?(Tree) or other.is_a?(Absence)) and other.include?(self) and self != other
    end

    ##
    # Checks if this tree is a subtree or equal to another tree.
    #
    # @param other [Object]
    # @return [Boolean]
    #
    # @example
    #   tree1 = Tree[a: 1, b: 2]
    #   tree2 = Tree[a: 1, b: 2, c: 3]
    #   tree1 <= tree2  # => true
    #   tree2 <= tree1  # => false
    #   tree1 <= tree1  # => true
    #
    def <=(other)
      (other.is_a?(Tree) or other.is_a?(Absence)) and other.include?(self)
    end

    ##
    # Checks if another tree is a subtree or equal to this tree.
    #
    # @param other [Object]
    # @return [Boolean]
    #
    # @example
    #   tree1 = Tree[a: 1, b: 2]
    #   tree2 = Tree[a: 1, b: 2, c: 3]
    #   tree1 >= tree2  # => false
    #   tree2 >= tree1  # => true
    #   tree1 >= tree1  # => true
    #
    def >=(other)
      (other.is_a?(Tree) or other.is_a?(Absence)) and self.include?(other)
    end

    ##
    # Checks if another tree is a subtree or equal to this tree.
    #
    # @param other [Object]
    # @return [Boolean]
    #
    # @example
    #   tree1 = Tree[a: 1, b: 2]
    #   tree2 = Tree[a: 1, b: 2, c: 3]
    #   tree1 > tree2  # => false
    #   tree2 > tree1  # => true
    #   tree1 > tree1  # => false
    #
    def >(other)
      (other.is_a?(Tree) or other.is_a?(Absence)) and self.include?(other) and self != other
    end

    ##
    # Checks if another object matches this tree structurally and by content.
    #
    # @param other [Object]
    # @return [Boolean]
    #
    # @example
    #   Tree[foo: :bar] === Hash[foo: :bar]  # => true
    #   Tree[1, 2, 3]   === Array[1, 2, 3]   # => true
    #   Tree[42]        === 42               # => true
    #
    # @todo This should probably apply a less strict equivalence comparison on the nodes.
    #   Problem: Requires a solution which doesn't use +Hash#include?+.
    #
    def matches?(other)
      case
        when Tree.like?(other)       then matches_tree?(other)
        when other.is_a?(Enumerable) then matches_enumerable?(other)
                                     else matches_atom?(other)
      end
    end

    alias === matches?

    private def matches_atom?(other)
      not other.nil? and (size == 1 and nodes.first == other and leaf? other)
    end

    private def matches_enumerable?(other)
      size == other.size and
        all? { |node, child| child.empty? and other.include?(node) }
    end

    private def matches_tree?(other)
      size == other.size and
        all? { |node, child|
          if child.nothing?
            other.include?(node) and begin other_child = other.fetch(node, nil)
              not other_child or
                (other_child.respond_to?(:empty?) and other_child.empty?)
            end
          else
            child.matches? other[node]
          end }
    end


    ########################################################################
    # @group Conversion
    ########################################################################

    ##
    # A native Ruby object representing the content of the tree.
    #
    # It is used by {#to_h} to produce flattened representations of child trees.
    #
    # @api private
    #
    def to_native_object
      case
        when empty?         then []
        when strict_leaves? then size == 1 ? nodes.first : nodes
                            else to_h
      end
    end

    ##
    # A hash representation of this tree.
    #
    # @return [Hash]
    #
    def to_h
      return {} if empty?

      # not the nicest, but fastest way to inject on hashes, as noted here:
      # http://stackoverflow.com/questions/3230863/ruby-rails-inject-on-hashes-good-style
      hash = {}
      @data.each do |node, child|
        hash[node] = child.to_native_object
      end

      hash
    end

    ##
    # A string representation of this tree.
    #
    # @return [String]
    #
    def to_s
      if (content = to_native_object).is_a? Enumerable
        "Tree[#{content.inspect[1..-2]}]"
      else
        "Tree[#{content.inspect}]"
      end
    end

    ##
    # A developer-friendly string representation of this tree in the usual Ruby +Object#inspect+ style.
    #
    # @return [String]
    #
    def inspect
      "#<#{self.class}:0x#{object_id.to_s(16)} #{to_h.inspect}>"
    end

    ##
    # Checks if the given object can be converted into a Tree.
    #
    # Ideally these would be implemented with Refinements, but since they
    # aren't available anywhere (I'm looking at you, JRuby), we have to be
    # content with this.
    #
    # @param object [Object]
    # @return [Boolean]
    #
    # @api private
    #
    def self.tree_like?(object)
      case object
        when Hash, Tree, Absence # ... ?!
          true
        else
          (object.respond_to? :tree_like? and object.tree_like?) # or ...
      end
    end

    class << self
      alias like? tree_like?
    end


    ########################################################################
    # @group Other standard Ruby methods
    ########################################################################

    ##
    # Duplicates the whole tree.
    #
    # @return [Tree]
    #
    def dup
      duplicate = self.class.new.add(self)
      duplicate.taint if tainted?
      duplicate
    end

    ##
    # Clones the whole tree.
    #
    def initialize_clone(other)
      super
      @data = Hash.new
      add other
    end

    ##
    # Deep freezes the whole tree.
    #
    # @see http://ruby-doc.org/core/Object.html#method-i-freeze
    #
    def freeze
      @data.freeze
      each { |_, child| child.freeze }
      super
    end

  end  # Tree
end  # Sycamore
