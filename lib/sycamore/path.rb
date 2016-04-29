require 'forwardable'

module Sycamore

  ##
  # A compact, immutable representation of Tree paths, i.e. node sequences.
  #
  # This class is optimized for its usage in {Tree#each_path}, where it
  # can efficiently represent the whole tree as a set of paths by sharing the
  # parent paths.
  # It is not intended to be instantiated by the user.
  #
  # @example
  #   tree = Tree[foo: [:bar, :baz]]
  #   path1, path2 = tree.paths.to_a
  #   path1 == Sycamore::Path[:foo, :bar] # => true
  #   path2 == Sycamore::Path[:foo, :baz] # => true
  #   path1.parent.equal? path2.parent # => true
  #
  # @todo Measure the performance and memory consumption in comparison with a
  #   pure Array-based implementation (where tree nodes are duplicated), esp. in
  #   the most common use case of property-value structures.
  #
  class Path
    include Enumerable
    extend Forwardable

    attr_reader :node, :parent

    ########################################################################
    # @group Construction
    ########################################################################

    ##
    # @private
    #
    def initialize(parent, node)
      @parent, @node = parent, node
    end

    ##
    # @return the root of all Paths
    #
    def self.root
      ROOT
    end

    ##
    # Creates a new path.
    #
    # Depending on whether the first argument is a {Path}, the new Path is
    # {#branch}ed from this path or the {root}.
    #
    # @overload of(path, nodes)
    #   @param path [Path] the path from which should be {#branch}ed
    #   @param nodes [nodes]
    #   @return [Path] the {#branch}ed path from the given path, with the given nodes expanded
    #
    # @overload of(nodes)
    #   @param nodes [nodes]
    #   @return [Path] the {#branch}ed path from the {root}, with the given nodes
    #
    def self.of(*args)
      if (parent = args.first).is_a? Path
        parent.branch(*args[1..-1])
      else
        root.branch(*args)
      end
    end

    class << self
      private :new  # disable Path.new

      alias [] of
    end

    ########################################################################
    # @group Elements
    ########################################################################

    def_delegators :to_a, :[], :fetch

    ##
    # Returns a new path based on this path, but with the given nodes extended.
    #
    # @param nodes [nodes] an arbitrary number of nodes
    # @return [Path]
    #
    # @raise [InvalidNode] if one or more of the given nodes is an Enumerable
    #
    # @example
    #   path = Sycamore::Path[:foo, :bar]
    #   path.branch(:baz, :qux) ==
    #     Sycamore::Path[:foo, :bar, :baz, :qux]  # => true
    #   path / :baz / :qux ==
    #     Sycamore::Path[:foo, :bar, :baz, :qux]  # => true
    #
    def branch(*nodes)
      return branch(*nodes.first) if nodes.size == 1 and nodes.first.is_a? Enumerable

      parent = self
      nodes.each do |node|
        raise InvalidNode, "#{node} in Path #{nodes.inspect} is not a valid tree node" if
          node.is_a? Enumerable
        parent = Path.__send__(:new, parent, node)
      end

      parent
    end

    alias + branch
    alias / branch

    ##
    # @return [Path] the n-th last parent path
    # @param distance [Integer] the number of nodes to go up
    #
    # @example
    #   path = Sycamore::Path[:foo, :bar, :baz]
    #   path.up     # => Sycamore::Path[:foo, :bar]
    #   path.up(2)  # => Sycamore::Path[:foo]
    #   path.up(3)  # => Sycamore::Path[]
    #
    def up(distance = 1)
      raise TypeError, "expected an integer, but got #{distance.inspect}" unless
        distance.is_a? Integer

      case distance
        when 1 then @parent
        when 0 then self
        else parent.up(distance - 1)
      end
    end

    ##
    # @return [Boolean] if this is the root path
    #
    def root?
      false
    end

    ##
    # @return [Integer] the number of nodes on this path
    #
    def length
      i, parent = 1, self
      i += 1 until (parent = parent.parent).root?
      i
    end

    alias size length

    ##
    # Iterates over all nodes on this path.
    #
    # @overload each_node
    #   @yield [node] each node
    #
    # @overload each_node
    #   @return [Enumerator<node>]
    #
    def each_node(&block)
      return enum_for(__callee__) unless block_given?

      if @parent
        @parent.each_node(&block)
        yield @node
      end
    end

    alias each each_node

    ##
    # If a given structure contains this path.
    #
    # @param struct [Object]
    # @return [Boolean] if the given structure contains the nodes on this path
    #
    # @example
    #   hash = {foo: {bar: :baz}}
    #   Sycamore::Path[:foo, :bar].present_in? hash  # => true
    #   Sycamore::Path[:foo, :bar].present_in? Tree[hash]  # => true
    #
    def present_in?(struct)
      each do |node|
        case
          when struct.is_a?(Enumerable)
            return false unless struct.include? node
            struct = (Tree.like?(struct) ? struct[node] : Nothing )
          else
            return false unless struct.eql? node
            struct = Nothing
        end
      end
      true
    end

    alias in? present_in?

    ########################################################################
    # @group Equality
    ########################################################################

    ##
    # @return [Fixnum] hash code for this path
    #
    def hash
      to_a.hash ^ self.class.hash
    end

    ##
    # @return [Boolean] if the other is a Path with the same nodes in the same order
    # @param other [Object]
    #
    def eql?(other)
      other.is_a?(self.class) and
        self.length == other.length and begin
          i = other.each ; all? { |node| node.eql? i.next }
        end
    end

    ##
    # @return [Boolean] if the other is an Enumerable with the same nodes in the same order
    # @param other [Object]
    #
    def ==(other)
      other.is_a?(Enumerable) and self.length == other.length and begin
        i = other.each ; all? { |node| node == i.next }
      end
    end

    ########################################################################
    # @group Conversion
    ########################################################################

    ##
    # @return [String] a string created by converting each node on this path to a string, separated by the given separator
    # @param separator [String]
    #
    # @note Since the root path with no node is at the beginning of each path,
    #   the returned string always begins with the given separator.
    #
    # @example
    #   Sycamore::Path[1,2,3].join       # => '/1/2/3'
    #   Sycamore::Path[1,2,3].join('|')  # => '|1|2|3'
    #
    def join(separator = '/')
      @parent.join(separator) + separator + node.to_s
    end

    ##
    # @return [String] a compact string representation of this path
    #
    def to_s
      "#<Path: #{join}>"
    end

    ##
    # @return [String] a more verbose string representation of this path
    #
    def inspect
      "#<Sycamore::Path[#{each_node.map(&:inspect).join(',')}]>"
    end
  end

end
