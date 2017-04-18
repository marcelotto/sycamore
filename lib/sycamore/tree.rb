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
    ADDITIVE_COMMAND_METHODS = %i[add << replace add_node_with_empty_child
       clear_child_of_node] << :[]=

    # the names of all command methods, which delete elements from a Tree
    DESTRUCTIVE_COMMAND_METHODS = %i[delete >> clear compact replace
        clear_child_of_node] << :[]=

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
         node node! nodes keys child_of child_at dig fetch fetch_path search
         size total_size tsize height
         each each_path paths each_node each_key each_pair search] << :[]

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
    end

    protected def data
      @data ||= Hash.new
    end

    protected def clear_data
      @data = nil
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
    # @overload add(path)
    #   adds a {Path} of nodes
    #   @param path [Path]
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
    #   tree.add foo: 1, bar: {qux: 2}
    #   tree.add foo: [:node, [:nested, :values]]  # => raise Sycamore::InvalidNode, "[:nested, :values] is not a valid tree node"
    #   tree.add Sycamore::Path[1,2,3]
    #   tree.to_h  # => {:foo=>1, :bar=>{:qux=>2}, :baz=>nil, 1=>{2=>3}}
    #
    #   tree = Tree.new
    #   tree[:foo][:bar] << :baz
    #   tree[:foo] << { bar: 1, qux: 2 }
    #   tree.to_h  # => {:foo=>{:bar=>[:baz, 1], :qux=>2}}
    #
    def add(nodes_or_tree)
      case
        when nodes_or_tree.equal?(Nothing) then # do nothing
        when nodes_or_tree.is_a?(Tree)     then add_tree(nodes_or_tree)
        when Tree.like?(nodes_or_tree)     then add_tree(valid_tree! nodes_or_tree)
        when nodes_or_tree.is_a?(Path)     then add_path(nodes_or_tree)
        when nodes_or_tree.is_a?(Enumerable)
          nodes_or_tree.all? { |node| valid_node_element! node }
          nodes_or_tree.each { |node| add(node) }
        else add_node(nodes_or_tree)
      end

      self
    end

    alias << add

    protected def add_node(node)
      data[node] ||= Nothing

      self
    end

    ##
    # @api private
    #
    def clear_child_of_node(node)
      data[valid_node! node] = Nothing

      self
    end

    ##
    # @api private
    #
    def add_node_with_empty_child(node)
      valid_node! node

      if data.fetch(node, Nothing).nothing?
        data[node] = new_child(node)
      end

      self
    end

    private def add_child(node, children)
      return add_node(node) if Nothing.like?(children)

      add_node_with_empty_child(node)
      data[node] << children

      self
    end

    private def add_tree(tree)
      tree.each { |node, child| add_child(node, child) }

      self
    end

    private def add_path(path)
      return self if path.root?

      path.parent.inject(self) { |tree, node| # using a {} block to circumvent this Rubinius issue: https://github.com/rubinius/rubinius-code/issues/7
        tree.add_node_with_empty_child(node)
        tree[node]
      }.add_node path.node

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
    # @overload delete(path)
    #   deletes a {Path} of nodes
    #   @param path [Path]
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
    #   tree = Tree[foo: {bar: :baz, qux: nil}]
    #   tree.delete Sycamore::Path[:foo, :bar, :baz]
    #   tree.to_h  # => {foo: :qux}
    #
    def delete(nodes_or_tree)
      case
        when nodes_or_tree.is_a?(Tree) then delete_tree(nodes_or_tree)
        when Tree.like?(nodes_or_tree) then delete_tree(valid_tree! nodes_or_tree)
        when nodes_or_tree.is_a?(Path) then delete_path(nodes_or_tree)
        when nodes_or_tree.is_a?(Enumerable)
          nodes_or_tree.all? { |node| valid_node_element! node }
          nodes_or_tree.each { |node| delete node }
        else
          delete_node valid_node!(nodes_or_tree)
      end

      self
    end

    alias >> delete

    protected def delete_node(node)
      data.delete(node)

      self
    end

    protected def delete_tree(tree)
      tree.each { |node_to_delete, child_to_delete| # using a {} block to circumvent this Rubinius issue: https://github.com/rubinius/rubinius-code/issues/7
        next unless include? node_to_delete
        if Nothing.like?(child_to_delete) or
            (child_to_delete.respond_to?(:empty?) and child_to_delete.empty?)
          delete_node node_to_delete
        else
          fetch(node_to_delete, Nothing).tap do |child|
            case
              when child.empty? then next
              when Tree.like?(child_to_delete)
                child.delete_tree(child_to_delete)
              when child_to_delete.is_a?(Enumerable)
                child_to_delete.each { |node| child.delete_node node }
              else
                child.delete_node child_to_delete
            end
            delete_node(node_to_delete) if child.empty?
          end
        end
      }

      self
    end

    protected def delete_path(path)
      case path.length
        when 0 then return self
        when 1 then return delete_node(path.node)
      end

      parent = fetch_path(path.parent) { return self }
      parent.delete_node(path.node)
      delete_path(path.parent) if parent.empty? and not path.parent.root?

      self
    end

    ##
    # Replaces the contents of this tree.
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
    # @overload replace(path)
    #   Replaces the contents of this tree with a path of nodes.
    #   @param path [Path]
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
    # An exception is the assignment of +nil+ or the {Nothing} tree: it will
    # delete the child tree at the given path entirely. If you really want to
    # overwrite the current child nodes with a single +nil+ node, you'll have to
    # assign an array containing only +nil+.
    #
    #   tree[:foo] = [nil]
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
    # @overload []=(*path, another_object)
    #   Replaces the contents of the child at the given path with another path of nodes.
    #   @param path [Array<Object>, Sycamore::Path] a path as a sequence of nodes or a {Path} object
    #   @param path_object [Path]
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
    #   tree[1] = Sycamore::Path[2,3]
    #   tree.to_h  # => {:foo => [:baz, :bar], 1 => {2 => 3}}
    #   tree[:foo] = Sycamore::Nothing
    #   tree.to_h  # => {:foo => nil, 1 => {2 => 3}}
    #
    def []=(*args)
      path, nodes_or_tree = args[0..-2], args[-1]
      raise ArgumentError, 'wrong number of arguments (given 1, expected 2)' if path.empty?

      if Nothing.like? nodes_or_tree
        if path.size == 1
          clear_child_of_node(path.first)
        else
          path, node = path[0..-2], path[-1]
          child_at(*path).clear_child_of_node(node)
        end
      else
        child_at(*path).replace(nodes_or_tree)
      end
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
      data.clear

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
      data.each do |node, child| case
          when child.nothing? then next
          when child.empty?   then clear_child_of_node(node)
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
      data.keys
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
    # @see Tree#node!
    #
    def node
      nodes = self.nodes
      raise NonUniqueNodeSet, "multiple nodes present: #{nodes}" if nodes.size > 1

      nodes.first
    end

    ##
    # The only node of this tree or an exception, if none or more {#nodes nodes} present.
    #
    # @return [Object] the single present node
    #
    # @raise [EmptyNodeSet] if no nodes present
    # @raise [NonUniqueNodeSet] if more than one node present
    #
    # @example
    #   tree = Tree[foo: 1, bar: [2,3]]
    #   tree[:foo].node!  # => 1
    #   tree[:baz].node!  # => raise Sycamore::EmptyNodeSet, "no node present"
    #   tree[:bar].node!  # => raise Sycamore::NonUniqueNodeSet, "multiple nodes present: [2, 3]"
    #
    # @see Tree#node
    #
    def node!
      raise EmptyNodeSet, 'no node present' if empty?
      node
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
    # @raise [InvalidNode] when given an +Enumerable+
    #
    # @example
    #   tree = Tree[foo: 1]
    #   tree.child_of(:foo).inspect  # "#<Sycamore::Tree:0x3fea48dd0e74 {1=>nil}>"
    #   tree.child_of(:bar).inspect  # "absent child of node :bar in #<Sycamore::Tree:0x3fea48dd0f3c {:foo=>1}>"
    #
    # @todo Should we differentiate the case of a leaf and a not present node? How?
    #
    def child_of(node)
      valid_node! node

      Nothing.like?(child = data[node]) ? Absence.at(self, node) : child
    end

    ##
    # The child tree of a node at a path.
    #
    # When a child at the given node path is not a present, an {Absence} object
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
    # @param node [Object, Path]
    # @param default [Object] optional
    # @return [Tree, default]
    #
    # @raise [InvalidNode] when given an +Enumerable+ as node
    # @raise [KeyError] when the given +node+ can't be found
    # @raise [ChildError] when no child for the given +node+ present
    #
    # @example
    #   tree = Tree[x: 1, y: nil, foo: {bar: :baz}]
    #   tree.fetch(:x)               # #<Sycamore::Tree:0x3fc798a63854(1)>
    #   tree.fetch(:y)               # => raise Sycamore::ChildError, "node :y has no child tree"
    #   tree.fetch(:z)               # => raise KeyError, "key not found: :z"
    #   tree.fetch(:z, :default)     # => :default
    #   tree.fetch(:y, :default)     # => :default
    #   tree.fetch(:z) { :default }  # => :default
    #   tree.fetch(Sycamore::Path[:foo, :bar]).nodes          # => [:baz]
    #   tree.fetch(Sycamore::Path[:foo, :missing], :default)  # => :default
    #
    # @todo Should we differentiate the case of a leaf and a not present node? How?
    #
    def fetch(node, *default, &block)
      return fetch_path(node, *default, &block) if node.is_a? Path
      valid_node! node

      child = data.fetch(node, *default, &block)
      if child.equal? Nothing
        child = case
          when block_given?    then yield
          when !default.empty? then default.first
          else raise ChildError, "node #{node.inspect} has no child tree"
        end
      end

      child
    end

    ##
    # The child tree of a node at a path.
    #
    # If the node at the given path can’t be found or has no child tree, it
    # behaves like {#fetch}.
    #
    # @param path [Array<Object>, Path]
    # @param default [Object] optional
    # @return [Tree, default]
    #
    # @raise [InvalidNode] when given an +Enumerable+ as node
    # @raise [KeyError] when the given +node+ can't be found
    # @raise [ChildError] when no child for the given +node+ present
    #
    # @example
    #   tree = Tree[foo: {bar: :baz}]
    #   tree.fetch_path([:foo, :bar]).nodes  # => [:baz]
    #   tree.fetch_path [:foo, :bar, :baz]   # => raise Sycamore::ChildError, "node :baz has no child tree"
    #   tree.fetch_path [:foo, :qux]         # => raise KeyError, "key not found: :qux"
    #   tree.fetch_path([:a, :b], :default)            # => :default
    #   tree.fetch_path([:a, :b]) { :default }         # => :default
    #   tree.fetch_path([:foo, :bar, :baz], :default)  # => :default
    #
    def fetch_path(path, *default, &block)
      default_case = block_given? || !default.empty?
      path.inject(self) do |tree, node|
        if default_case
          tree.fetch(node) { return block_given? ? yield : default.first }
        else
          tree.fetch(node)
        end
      end
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

      data.each_key(&block)

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

      data.each_pair(&block)

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
      case args.count
        when 0 then raise ArgumentError, 'wrong number of arguments (given 0, expected 1+)'
        when 1 then path = args.first
               else return include_path?(args)
      end
      path = [path] unless path.is_a? Enumerable

      if path.is_a? Path
        fetch_path(path.parent) { return false }.include? path.node
      else
        fetch_path(path[0..-2]) { return false }.include? path.last
      end
    end

    alias path? include_path?

    ##
    # Checks if a node exists in the {#nodes nodes} set of this tree.
    #
    # @param node [Object, Path]
    # @return [Boolean]
    #
    # @example
    #  Tree[1,2,3].include_node? 3   # => true
    #  Tree[1 => 2].include_node? 2  # => false
    #  Tree[1 => 2].include_node? Sycamore::Path[1,2]  # => true
    #
    def include_node?(node)
      return include_path?(node) if node.is_a? Path

      data.include?(node)
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
    # Searches the tree for one or multiple nodes or a complete tree.
    #
    # @param nodes_or_tree [Object, Array, Tree, Hash]
    # @return [Array<Path>]
    #
    # @example
    #   tree = Tree[ "a" => [:foo, 100], "b" => { foo: [:bar, :baz] } ]
    #   tree.search :bar          # => [Sycamore::Path["b", :foo]]
    #   tree.search :foo          # => [Sycamore::Path["a"], Sycamore::Path["b"]]
    #   tree.search [:bar, :baz]  # => [Sycamore::Path["b", :foo]]
    #   tree.search foo: :bar     # => [Sycamore::Path["b"]]
    #   tree.search 42            # => []
    #
    def search(nodes_or_tree)
      _search(nodes_or_tree)
    end

    protected def _search(query, current_path: Path::ROOT, results: [])
      results << current_path if include?(query)
      each do |node, child|
        child._search(query, current_path: current_path/node, results: results)
      end
      results
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
      data.size
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
      data.each { |_, child| total += child.total_size }
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
      data.empty?
    end

    alias blank? empty?

    ##
    # Checks if the given node has no children.
    #
    # @param node [Object, Path]
    # @return [Boolean]
    #
    # @example
    #   tree = Tree[x: 1, y: [], z: nil]
    #   tree.leaf?(:x)  # => false
    #   tree.leaf?(:y)  # => true
    #   tree.leaf?(:z)  # => true
    #   tree.leaf?(Sycamore::Path[:x, 1])  # => true
    #
    def leaf?(node)
      include_node?(node) && child_at(node).empty?
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
    #   tree.strict_leaf?(Sycamore::Path[:x, 1])  # => true
    #
    def strict_leaf?(node)
      include_node?(node) && child_at(node).absent?
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
    #   @param nodes [Array<Object, Path>] splat of nodes or Path objects
    #   @return [Boolean]
    #
    # @example
    #   Tree[1,2,3].strict_leaves?  # => true
    #   tree = Tree[x: 1, y: [], z: nil]
    #   tree.strict_leaves?          # => false
    #   tree.strict_leaves?(:x, :y)  # => false
    #   tree.strict_leaves?(:y, :z)  # => false
    #   tree.strict_leaves?(:y, :z)  # => false
    #   tree.strict_leaves?(:z, Sycamore::Path[:x, 1])  # => true
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
    #   @param nodes [Array<Object, Path>] splat of nodes or Path objects
    #   @return [Boolean]
    #
    # @example
    #   Tree[1,2,3].leaves?  # => true
    #   tree = Tree[x: 1, y: [], z: nil]
    #   tree.external?          # => false
    #   tree.external?(:x, :y)  # => false
    #   tree.external?(:y, :z)  # => true
    #   tree.external?(:y, :z)  # => true
    #   tree.external?(Sycamore::Path[:x, 1], :y)  # => true
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
    #   @param nodes [Array<Object, Path>] splat of nodes or Path objects
    #   @return [Boolean]
    #
    # @example
    #   Tree[x: 1, y: 2].internal?  # => true
    #   tree = Tree[x: 1, y: [], z: nil]
    #   tree.internal?          # => false
    #   tree.internal?(:x, :y)  # => false
    #   tree.internal?(:y, :z)  # => false
    #   tree.internal?(:x)      # => true
    #   tree.internal?(:x)      # => true
    #   tree.internal?(Sycamore::Path[:x, 1])  # => false
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

    ##
    # Search all nodes for a given string.
    # Returns array of paths for nodes containing the string.
    #
    # @example
    #   tree = Tree.new
    #   tree[:name, "Dewayne"] << {skill: "Ruby"}
    #   tree[:name, "Dewayne"] << {skill: "Ada"}
    #   tree[:name, "Marcel"] << {skill: "Ruby"}
    #   tree[:name, "Marcel"] << {author_of: "sycamore"}
    #   tree.search("Ruby") 
    #     #=> [#<Sycamore::Path[:name,"Dewayne",:skill,"Ruby"]>, 
    #          #<Sycamore::Path[:name,"Marcel",:skill,"Ruby"]>]
    #
    #
    def search(a_string)
      self.each_path.select{|a_path| a_path.join('/').downcase.include?(a_string.downcase)}
    end


    ########################################################################
    # @group Comparison
    ########################################################################

    ##
    # A hash code of this tree.
    #
    # @return [Fixnum]
    #
    def hash
      data.hash ^ self.class.hash
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
      (other.instance_of?(self.class) and data.eql?(other.data)) or
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
    def to_native_object(sleaf_child_as: nil, special_nil: false)
      case
        when empty?
          []
        when strict_leaves?
          size == 1 && (!special_nil || !nodes.first.nil?) ? nodes.first : nodes
        else
          to_h(sleaf_child_as: sleaf_child_as, special_nil: special_nil)
      end
    end

    ##
    # A hash representation of this tree.
    #
    # @return [Hash]
    #
    def to_h(*args)
      return {} if empty?

      # not the nicest, but fastest way to inject on hashes, as noted here:
      # http://stackoverflow.com/questions/3230863/ruby-rails-inject-on-hashes-good-style
      hash = {}
      data.each do |node, child|
        hash[node] = child.to_native_object(*args)
      end

      hash
    end

    ##
    # A string representation of this tree.
    #
    # @return [String]
    #
    def to_s
      if (content = to_native_object(special_nil: true)).is_a? Enumerable
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
      "#<#{self.class}:0x#{object_id.to_s(16)} #{
            to_h(sleaf_child_as: Sycamore::NothingTree::NestedString).inspect}>"
    end

    # @api private
    #
    private def valid_tree!(tree)
      tree.each { |node, child| # using a {} block to circumvent this Rubinius issue: https://github.com/rubinius/rubinius-code/issues/7
        next if child.nil?
        valid_node!(node)
        valid_tree!(child) if Tree.like?(child)
      }

      tree
    end

    # @api private
    #
    private def valid_node_element!(node)
      raise InvalidNode, "#{node} is not a valid tree node" if
        node.is_a?(Enumerable) and not node.is_a?(Path) and not Tree.like?(node)

      node
    end


    # @api private
    #
    private def valid_node!(node)
      raise InvalidNode, "#{node} is not a valid tree node" if node.is_a? Enumerable

      node
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
      clear_data
      add other
    end

    ##
    # Deep freezes the whole tree.
    #
    # @see http://ruby-doc.org/core/Object.html#method-i-freeze
    #
    def freeze
      data.freeze
      each { |_, child| child.freeze }
      super
    end

  end  # Tree
end  # Sycamore
