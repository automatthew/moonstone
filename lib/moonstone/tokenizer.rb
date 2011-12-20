module Moonstone
  class Tokenizer < Lucene::Analysis::Tokenizer

    include Lucene::Analysis

    def initialize(reader)
      @reader = java.io.BufferedReader.new(reader)
    end

    # No, this is not terribly useful.  Subclass me already.
    def next(token=nil)
      token = (token ? token.clear :  Token.new)
      token.set_term_text @reader.read_line
      token.set_start_offset 1
      token.set_end_offset 1
    end

  end
end