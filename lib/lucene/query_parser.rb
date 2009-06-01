module Lucene
  module QueryParser
    include_package "org.apache.lucene.queryParser"
    
    # avoid problems with Lucene::QueryParser::QueryParser
    Parser = org.apache.lucene.queryParser.QueryParser
    
    # Biggie Smalls, Biggie Smalls, Biggie Smalls
    [
      MultiFieldQueryParser,
      Token
      ]
  end
end