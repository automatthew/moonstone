module Lucene
  module QueryParser
    include_package "org.apache.lucene.queryParser"
    
    # avoid problems with Lucene::QueryParser::QueryParser
    Parser = org.apache.lucene.queryParser.QueryParser
    
    # Mention classes so they can be referenced elsewhere
    [
      MultiFieldQueryParser,
      Token
      ]
  end
end