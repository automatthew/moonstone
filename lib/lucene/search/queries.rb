module Lucene
  module Search
    include_package "org.apache.lucene.search"
    
    TermQuery.module_eval do
      
      def self.new(*args)
        term = args.first.is_a?(Lucene::Index::Term) ? args.first : Lucene::Index::Term.new(*args)
        super(term)
      end
      
    end
    
    BooleanQuery.module_eval do
      
      def self.and(*queries)
        q = self.new
        queries.each { |query| q.add(query, BooleanClause::Occur::MUST) }
        q
      end
      
      def self.or(*queries)
        q = self.new
        queries.each { |query| q.add(query, BooleanClause::Occur::SHOULD) }
        q
      end
      
      def self.not(*queries)
        q = self.new
        queries.each { |query| q.add(query, BooleanClause::Occur::MUST_NOT) }
        q
      end
      
      def and(*queries)
        queries.each { |query| add(query, BooleanClause::Occur::MUST) }
        self
      end
      
      def or(*queries)
        queries.each { |query| add(query, BooleanClause::Occur::SHOULD) }
        self
      end
      
      def not(*queries)
        queries.each { |query| add(query, BooleanClause::Occur::MUST_NOT) }
        self
      end
            
    end
    
    PhraseQuery.module_eval do
      def self.create(field, phrase)
        raise "I need an array" unless phrase.is_a? Array
        query = self.new
        phrase.each do |word|
          query.add(Index::Term.new(field, word))
        end
        query
      end
    end
    
  end
end