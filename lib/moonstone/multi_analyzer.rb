module Moonstone
  class MultiAnalyzer < Lucene::Analysis::Analyzer
    attr_accessor :fields
    
    # Moonstone::MultiAnalyzer.new  :name => [KeywordTokenizer, SynonymFilter], 
    #                               :categories => [WhitespaceTokenizer, SynonymFilter, StemFilter]
    def self.new(hash={})
      analyzer = super()
      analyzer.fields = hash
      analyzer
    end
    
    def tokenStream(field_name, reader)
      filter_chain = @fields[field_name.to_sym] || @fields[true]
      tokenizer, *args = filter_chain[0]
      stream = tokenizer.new(reader, *args)
      filter_chain.slice(1..-1).each do |filter|
        klass, *args = filter
        stream = klass.new(stream, *args)
      end
      stream
    end
    
  end
end
