module Lucene
  module Search
    include_package "org.apache.lucene.search"
    
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
  end
end