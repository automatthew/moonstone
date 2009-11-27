module Lucene
  module Search
    include_package "org.apache.lucene.search"
    
    [ SortField, Sort ]
    
    # Deprecated
    Hit.module_eval do
      alias_method :[], :get
    end
    
    # Deprecated
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
    
    
    # TODO:  This doesn't exactly belong here, but I'm
    # not sure where to put non-core things
    module Spell
      include_package 'org.apache.lucene.search.spell'
      [PlainTextDictionary]
    end
    

    
    # Mention classes so they can be referenced elsewhere
    [
      Explanation,
      Collector,
      FilteredQuery,
      FuzzyQuery,
      HitIterator,
      MultiPhraseQuery,
      PrefixQuery,
      Query,
      RangeQuery,
      ScoreDoc,
      Scorer,
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