module Lucene
  module Store
    include_package "org.apache.lucene.store"

    # Biggie Smalls, Biggie Smalls, Biggie Smalls
    [
      Directory,
      FSDirectory,
      RAMDirectory
      ]
  end
end