module Moonstone
  class Analyzer < Lucene::Analysis::Analyzer
    attr_accessor :filter_chain
    # Moonstone::Analyzer.new(WhitespaceTokenizer, StandardFilter, StemFilter)
    # FIXME:  Why don't we explicitly require a tokenizer + *filters ?
    def self.new(*classes)
      analyzer = super()
      analyzer.filter_chain = classes
      analyzer
    end

    def tokenStream(field_name, reader)
      tokenizer, *args = @filter_chain[0]
      stream = tokenizer.new(reader, *args)
      @filter_chain.slice(1..-1).each do |filter|
        klass, *args = filter
        stream = klass.new(stream, *args)
      end
      stream
    end

  end
end
