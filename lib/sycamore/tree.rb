module Sycamore

  ############################################################################
  # Tree factory function
  #
  # a convenience method for the constructor
  #
  # @example  So, instead of
  #
  #     Sycamore::Tree.new(...)
  #
  #   you can write
  #
  #     Sycamore::Tree(...)
  #
  # @see For an even more convient method, see also the unqualified usage.
  #
  def self.Tree(*args, &block)
    Sycamore::Tree.new(*args, &block)
  end


  ############################################################################
  # Tree class
  #
  # A data structure for a mapping of nodes to other {Tree}s,
  #   containing nodes with more {Tree}s ...
  #
  #
  class Tree

    ################################################################
    # creation                                                     #
    ################################################################

    def initialize
      @map = Hash.new
    end


    ################################################################
    # nodes and children                                           #
    ################################################################

    include CQS

    #####################
    #  query interface  #
    #####################

    def empty?
      query_return @map.empty?
    end

    #####################
    # command interface #
    #####################


    ########################################
    # Nodes
    ########################################

    #####################
    #  query interface  #
    #####################

    #####################
    # command interface #
    #####################


    ########################################
    # Children
    ########################################

    #####################
    #  query interface  #
    #####################

    #####################
    # command interface #
    #####################



    ################################################################
    # Enumerable                                                   #
    ################################################################



    ################################################################
    # equality as recursive node equivalence                       #
    ################################################################



    ################################################################
    # conversion                                                   #
    ################################################################




  end
end
