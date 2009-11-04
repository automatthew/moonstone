module Lucene
  module Search
    include_package "org.apache.lucene.search"
    
    [ SortField, Sort ]
    
    Hit.module_eval do
      alias_method :[], :get
    end
    
    Hits.module_eval do
      include Enumerable
      def each
        i = 0
        while i < length do
          yield doc(i)
          i += 1
        end
      end
      
      alias_method :size, :length
    end
    
    TopDocs.module_eval do
      attr_accessor :query
      include Enumerable
            
      def each(&block)
        scoreDocs.each(&block)
      end
      
      def each_doc(searcher)
        scoreDocs.each do |sd|
          doc = searcher.doc(sd.doc)
          doc.score = sd.score
          doc.id = sd.doc
          yield(doc)
        end
      end
      
      def documents(searcher, &block)
        docs = []
        if block_given?
          each_doc(searcher) { |d| yield(d); docs << d  }
        else
          each_doc(searcher) { |d| docs << d  }
        end
        docs
      end
            
      def [](index)
        scoreDocs[index]
      end
      
      def first
        scoreDocs[0]
      end
      
      def last
        scoreDocs[scoreDocs.length - 1]
      end
      
      def length
        scoreDocs.length - (@offset || 0)
      end
      
      alias_method :size, :length
      
      def empty?
        self.length <= 0
      end
      
      def to_hash
        {
          :query => self.query,
          :total_hits => self.totalHits,
          :documents => self.documents
        }
      end
      
      def to_json
        to_hash.to_json
      end

      
    end
    
    IndexSearcher.module_eval do
      def self.open(*args)
        searcher = new(*args)
        begin
          result = yield(searcher)
        ensure
          searcher.close
        end
        result
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
    
    TermQuery.module_eval do
      
      def self.new(*args)
        term = args.first.is_a?(Lucene::Index::Term) ? args.first : Lucene::Index::Term.new(*args)
        super(term)
      end
      
    end
    
    module Spell
      include_package 'org.apache.lucene.search.spell'
      [PlainTextDictionary]
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
    
    
    # Biggie Smalls, Biggie Smalls, Biggie Smalls
    [
      Explanation,
      FilteredQuery,
      FuzzyQuery,
      HitIterator,
      MultiPhraseQuery,
      PrefixQuery,
      Query,
      RangeQuery,
      ScoreDoc,
      Searcher,
      Similarity,
      TopDocCollector,
      TopFieldDocCollector,
      TopFieldDocs,
      Weight,
      WildcardQuery
      ]
  end
end