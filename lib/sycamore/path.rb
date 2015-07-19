module Sycamore

  ############################################################################
  #
  # Path factory function
  #
  # A convenience method for the constructor. With it, you can write
  #
  #     Sycamore::Path(...) { ... }
  #
  # instead of the longer
  #
  #     Sycamore::Path.new(...) { ... }
  #
  # @see For an even more convenient method, see the unqualified usage with
  #   the global {::Path()} function.
  #
  def self.Path(*args, &block)
    Sycamore::Path.of(*args, &block)
  end

  class Path

    attr_reader :node, :parent

    include Enumerable

    ################################################################
    # Creation and factories
    ################################################################

    class << self

      private :new

      def root
        ROOT
      end

      def of(*args, &block)
        if (parent = args.first).is_a? Path
          parent.branch(*args[1..-1], &block)
        else
          root.branch(*args, &block)
        end
      end

      alias [] of
    end


    def initialize(parent, node, &block)
      @parent, @node = parent, node
    end


    def branch(*path, &block)
      return branch(*path.first) if path.size == 1 and path.first.is_a? Enumerable
      parent = self
      path.each do |node|
        raise IndexError, "nil value in path of #{path}" if node.nil?
        parent = Path.__send__(:new, parent, node)
      end
      parent
    end

    alias [] branch
    alias /  branch
    # TODO: alias +  branch ???
    alias with branch


    ################################################################
    # Element access
    ################################################################

    def up(distance = 1)
      case distance
        when 1 then @parent
        when 0 then self
        else parent.up(distance - 1)
      end
    end


    def root?
      false
    end


    # TODO: each_node or each_component or each ... ?
    def each_node(&block)
      return enum_for(__callee__) unless block_given?
      if @parent
        @parent.each_node(&block)
        yield @node
      end
    end

    alias each each_node


    def length
      i, parent = 1, self
      i += 1 until (parent = parent.parent).root?
      i
    end

    alias size length



    ################################################################
    # general integration with object supporting the
    #   Tree-structure-protocol (incl. Hash)
    ################################################################

    def present_in?(struct)
      each do |node|
        return false unless struct
        next struct = nil if node == struct
        struct = struct.fetch(node) { return false }
      end
      true
    end

    alias in? present_in?


    # TODO: Spec this ...
    # def fetch_from(struct)
    # end

    # TODO: alias ??? fetch


    ################################################################
    # equality and equivalence
    ################################################################

    def ==(other)
      self.length == other.length and begin
        i = other.each ; all? { |node| node == i.next }
      end
    end

    def eql?(other)
      other.is_a?(self.class) and
        self.length == other.length and begin
          i = other.each ; all? { |node| node.eql? i.next }
        end
    end

    def hash
      [to_a, self.class].hash
    end


    ################################################################
    # conversion
    ################################################################

    # Generalize to a serialization, which can be decoded via #from ...
    def to_s
      to_a.join '/' # TODO: extract the delimiter symbol into a ... ?
      # each
      #  .map {|node| node.is_a? Symbol ? ":#{node}" }
      #  .join self.class.delimiter
    end

    def inspect
      "#<Sycamore::Path[#{each_node.map(&:inspect).join(',')}]>"
    end


    ################################################################
    # Various other Ruby protocols
    ################################################################

    # Should we freeze Paths by default?
    # def freeze
    #   raise NotImplementedError
    # end

  end

end
