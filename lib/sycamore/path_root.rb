require 'singleton'

module Sycamore

  class Path
    class Root < Path
      include Singleton

      def initialize
        @parent, @node = nil, :root
      end

      def root?
        true
      end

      def length
        0
      end

      def up(distance = 1)
        self
      end

      def to_s
        "#<Sycamore::Path::Root>"
      end

      def inspect
        to_s
        # TODO: "???"
      end

    end

    ROOT = Root.instance
  end

end
