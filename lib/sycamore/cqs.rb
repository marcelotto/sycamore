module Sycamore

  # Command-Query-Separation for {Sycamore::Tree}s
  #
  module CQS

    # TODO when lazy arguments solved
    #   private def query_return(result, name: nil, sender: nil, args: nil)
    private def query_return(result)
      result
    end


    # TODO when lazy arguments solved
    #   private def command_return(name: nil, sender: nil, args: nil)
    private def command_return
      self
    end

  end
end
