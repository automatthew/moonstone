module Lucene
  module Search
    module Function
      include_package 'org.apache.lucene.search.function'
      
      [FieldScoreQuery, CustomScoreQuery]
    end
  end
end