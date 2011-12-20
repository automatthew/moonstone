module Moonstone
  class Engine
    include Lucene::Index
    include Lucene::Search
    include Lucene::Document

    attr_reader :store, :similarity

    # :store should be a String or some kind of Lucene::Store::Directory
    def initialize(options = {})
      @store = options[:store] || Lucene::Store::RAMDirectory.new
      @inspect = options[:inspect]
    end

    # The source should be enumerable.
    def index(source, optimize=true)
      IndexWriter.open(@store, analyzer) do |writer|
        writer.set_similarity(@similarity.new) if @similarity

        source.each_with_index do |record, i|
          doc = doc_from(record)
          writer.add_document(doc) if doc
          Moonstone::Logger.info "Indexed #{i+1} records" if (i+1)%1000 == 0
        end
        writer.optimize if optimize
        yield writer if block_given? #For post-processing stuff where you still need access to the writer
      end
      refresh_searcher
    end

    def stamp_metadata
      metadata = Lucene::Document::Doc.new
      metadata.add_field 'metadata', 'index', :index => :not_analyzed
      metadata.add_field 'build_date', Date.today.strftime("%Y-%m-%d"), :index => false
      metadata.add_field 'engine_name', self.class.name, :index => false
      metadata.add_field 'engine_version', `git show-ref -s --abbrev HEAD`.chomp, :index => false
      metadata.add_field 'query_conditions', ENV['query_conditions'].to_s, :index => false
      writer do |w|
        w.add_document(metadata)
      end
    end

    def index_metadata
      query = TermQuery.new 'metadata', 'index'
      @index_metadata ||= search(query).last
    end

    def doc_count
      @reader ||= IndexReader.open(@store)
      @reader.max_doc
    end

    def document(id)
      @reader ||= IndexReader.open(@store)
      if id < @reader.max_doc
        doc = @reader.document(id)
        doc.tokens = tokens_for_doc(id)
        doc.id = id
        doc
      end
    end

    # Adds docs to index.  docs must be an enumerable set of such objects that doc_from can turn into a document
    def insert_documents(source, optimize=false)
      index(source, optimize)
      refresh_searcher
    end

    def insert_document(source, optimize=false)
      insert_documents([source], optimize)
    end

    # docs must be enumerable set of hashes, with fields
    # :field, :value, :document
    # (where field and value combine to make a term to match documents to replace)
    def update_documents(docs)
      IndexWriter.open(@store, analyzer) do |writer|
        writer.set_similarity(@similarity.new) if @similarity
        docs.each do |doc|
          raise "Invalid arguments" unless doc[:field] && doc[:value] && doc[:document]
          term = Term.new(doc[:field], doc[:value])
          document = doc_from(doc[:document])
          writer.updateDocument(term, document)
        end
      end
      refresh_searcher
    end

    def update_document(doc)
      update_documents([doc])
    end

    # terms should be an enumerable set of hashes, with fields
    # :field and :value, which combine to make a term to match documents to delete
    def delete_documents(terms)
      IndexWriter.open(@store, analyzer) do |writer|
        terms.each do |t|
          term = Term.new(t[:field], t[:value])
          writer.deleteDocuments(term)
        end
      end
      refresh_searcher
    end

    def delete_document(term)
      delete_documents([term])
    end

    def optimize
      IndexWriter.open(@store, analyzer) do |writer|
        writer.optimize
      end
      refresh_searcher
    end

    # Takes any kind of input object parsable by your #create_query method.  Quack.
    # Options patterns (see javadoc for org.apache.lucene.search.Searcher):
    # Returns a TopDocs object
    # Note that Hits is deprecated so the versions of search() returning a Hits object are not implemented
    def search(input, options = {})
      query = input.kind_of?(Lucene::Search::Query) ? input : create_query(input)
      @searcher ||= IndexSearcher.new(@store)
      top_docs = if (hit_collector = options[:hit_collector])
        args = [ options[:filter], hit_collector ].compact
        @searcher.search(query, *args)
        hit_collector.topDocs
      else
        options[:limit] ||= 25
        options[:offset] ||= 0
        args = [ options[:filter], (options[:limit] + options[:offset]) ]  #Always include both of these, even if nil
        args << options[:sort] if options[:sort]
        @searcher.search(query, *args).offset!(options[:offset])
      end
      top_docs.each(@searcher) do |doc|
        doc.tokens = self.tokens_for_doc(doc) if inspect_mode?
        yield doc if block_given?
      end
      top_docs
    end

    #Reopen the searcher (used when the index has changed)
    def refresh_searcher
      @searcher = IndexSearcher.new(@store) if @searcher  #If it's nil, it'll get lazy loaded
    end

    def close
      @searcher.close if @searcher
      @searcher = nil
      @reader.close if @reader
      @reader = nil
    end

    def create_query(query_string)
      raise "no default query parser" unless @default_query_parser
      @default_query_parser.parse(query_string)
    end

    # Returns an instance of the Analyzer class defined within
    # this class's namespace.
    def analyzer
      @analyzer ||= (defined?(self.class::Analyzer) ? self.class::Analyzer.new : Lucene::Analysis::StandardAnalyzer.new )
    end

    # Analyze and index all fields.
    # Override this method for custom behavior.
    def doc_from(record)
      Doc.create(record)
    end

    # Opens an IndexWriter for the duration of the block.
    #   engine.writer { |w| w.add_document(doc) }
    def writer
      IndexWriter.open(@store, analyzer) do |writer|
        writer.set_similarity(@similarity.new) if @similarity
        yield writer
      end
    end

    # Opens an IndexSearcher for the duration of the block.
    #   engine.searcher { |s| s.search(query_object) }
    def searcher
      IndexSearcher.open(@store) do |searcher|
        searcher.set_similarity(@similarity.new) if @similarity
        yield searcher
      end
    end

    # Opens an IndexReader for the duration of the block.
    #   engine.reader { |r| r.terms }
    def reader
      reader = IndexReader.open(@store)
        yield reader
      reader.close
    end

    def default_query_parser(field, analyzer = nil)
      @default_query_parser ||= Lucene::QueryParser::Parser.new(field, analyzer || self.analyzer)
    end

    def inspect_mode?
      @inspect
    end

  end
end
