require 'singleton'

module Sycamore
  class Path
    class Root < Path
      include Singleton

      def initialize
        @parent, @node = nil, nil
      end

      def up(distance = 1)
        super unless distance.is_a? Integer
        self
      end

      def root?
        true
      end

      def length
        0
      end

      def join(delimiter = '/')
        ''
      end

      def to_s
        '#<Path:Root>'
      end

      def inspect
        '#<Sycamore::Path::Root>'
      end
    end

    ROOT = Root.instance
  end
end
