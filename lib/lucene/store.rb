module Lucene
  module Store
    include_package "org.apache.lucene.store"
    
    # Mention classes so they can be referenced elsewhere
    [
      Directory,
      FSDirectory,
      RAMDirectory
      ]
  end
end