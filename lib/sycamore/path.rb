module Sycamore

  # A compact, immutable representation of Tree paths, i.e. node sequences.
  #
  # This class is optimized for its usage in {Tree@each_path}, where it
  # can efficiently represent the whole tree as a set of paths by sharing the
  # parent paths.
  #
  # This class is not intended to be instantiated by the user.
  # Tree methods which accept paths, always accept them always as arrays of nodes.
  #
  # @todo Measure the performance and memory consumption in comparison with a
  #   pure Array-based implementation (where tree nodes are duplicated), esp. in
  #   the most common use case of property-value structures.
  #
  class Path
    include Enumerable

    attr_reader :node, :parent

    ########################################################################
    # @group Construction
    ########################################################################

    class << self

      private :new

      def root
        ROOT
      end

      def of(*args)
        if (parent = args.first).is_a? Path
          parent.branch(*args[1..-1])
        else
          root.branch(*args)
        end
      end

      alias [] of
    end

    def initialize(parent, node)
      @parent, @node = parent, node
    end

    ########################################################################
    # @group Element access
    ########################################################################

    def branch(*path)
      return branch(*path.first) if path.size == 1 and path.first.is_a? Enumerable

      parent = self
      path.each do |node|
        raise InvalidNode, "#{node} in Path #{path.inspect} is not a valid tree node" if
          node.nil? or node.is_a? Enumerable
        parent = Path.__send__(:new, parent, node)
      end

      parent
    end

    alias +  branch
    alias /  branch

    def up(distance = 1)
      raise TypeError, "expected an integer, but got #{distance.inspect}" unless distance.is_a? Integer

      case distance
        when 1 then @parent
        when 0 then self
        else parent.up(distance - 1)
      end
    end

    # @return [Boolean] if this is the root
    #
    def root?
      false
    end

    # @return [Integer] the number of nodes on this path
    #
    def length
      i, parent = 1, self
      i += 1 until (parent = parent.parent).root?
      i
    end

    alias size length

    # enumerates over akk
    def each_node(&block)
      return enum_for(__callee__) unless block_given?

      if @parent
        @parent.each_node(&block)
        yield @node
      end
    end

    alias each each_node

    def present_in?(struct)
      each do |node|
        case
          when struct.nil?
            return false
          when struct.is_a?(Enumerable)
            return false unless struct.include? node
            struct = (Tree.like?(struct) ? struct[node] : nil )
          else
            return false unless struct.eql? node
            struct = nil
        end
      end
      true
    end

    alias in? present_in?

    ########################################################################
    # @group Equality
    ########################################################################

    def hash
      to_a.hash ^ self.class.hash
    end

    def eql?(other)
      other.is_a?(self.class) and
        self.length == other.length and begin
          i = other.each ; all? { |node| node.eql? i.next }
        end
    end

    def ==(other)
      other.is_a?(Enumerable) and self.length == other.length and begin
        i = other.each ; all? { |node| node == i.next }
      end
    end

    ########################################################################
    # @group Conversion
    ########################################################################

    def join(delimiter = '/')
      @parent.join(delimiter) + delimiter + node.to_s
    end

    def to_s
      "#<Path: #{join}>"
    end

    def inspect
      "#<Sycamore::Path[#{each_node.map(&:inspect).join(',')}]>"
    end
  end

end
