module Moonstone
  module Contrib
    
    class NaiveCollector < Lucene::Search::Collector
      attr_accessor :reader, :searcher, :docs
      
      def initialize(reader, searcher)
        super()
        @reader, @searcher = reader, searcher
        @docs = []
      end
      
      def collect(doc_id)
        @docs << @reader.document(doc_id)
      end
      
      def setNextReader(reader, docbase)
        
      end
      
      def acceptsDocsOutOfOrder()
        true
      end
      
      def setScorer(scorer)
        
      end
      
    end
    
  end
end
