require "#{here = File.dirname(__FILE__)}/../helpers.rb"

include Lucene
include Lucene::Analysis
include Lucene::Index
include Lucene::QueryParser
include Lucene::Search
include Lucene::Store
include Lucene::Document

describe "The low level Lucene wrapper (plus some sugar)" do
  
  before do
    @store = RAMDirectory.new
    @analyzer = StandardAnalyzer.new
    document1 = Doc.new
    document1.add(Field.new("filename", "donkey_stink", Field::Store::YES, Field::Index::NO))
    document1.add(Field.new("contents", "Donkeys stink as much as monkeys", Field::Store::YES, Field::Index::ANALYZED))
    document2 = Doc.new
    file = "#{here}/tmp/docs/monkey_stink"
    keyword = Field.new("filename", file, Field::Store::YES, Field::Index::NO)
    contents = Field.new("contents", java.io.FileReader.new(file))
    document2.add(keyword)
    document2.add(contents)
    @documents = [document1, document2]
  end

  after do
    @store.close
  end

  it "can be used much like native Lucene" do
    writer = IndexWriter.new(@store, @analyzer, true)
    @documents.each { |doc| writer.add_document(doc) }
    writer.close
    @documents.first.fields.map { |f| f.name }.should == ["filename", "contents"]
    reader = IndexReader.open(@store)
    terms = reader.terms.map { |term| term.text }
    terms.sort.should == %w{ donkeys stink much monkeys frequently }.sort
    reader.close
  end
  
  
  it "adds an IO.open-ish open method to IndexWriter" do
    IndexWriter.open(@store, @analyzer, true) do |writer|
      @documents.each { |doc| writer.add_document(doc) }
    end
    terms = IndexReader.open(@store).terms
    terms.map { |term| term.text }.sort.should == %w{ donkeys frequently stink much monkeys }.sort
  end
  
  it "endows IndexWriter with #add_documents" do
    IndexWriter.open(@store, @analyzer, true) do |writer|
      writer.add_documents(@documents)
    end
    reader = IndexReader.open(@store)
    terms = reader.terms.map { |term| term.text }
    terms.sort.should == %w{ donkeys frequently stink much monkeys }.sort
    reader.close
  end
  
  it "endows Document::Document with flexible #add_field " do
    doc1 = Doc.new
    doc1.add_field("filename", "donkey_stink", :store => true, :index => false)
    doc1.add_field("contents", "Donkeys stink like monkeys.", :store => true, :index => :analyzed)
    
    doc2 = Doc.new
    doc2.add_field("filename", "snake_stink", :index => false)
    doc2.add_field("contents", "Snakes just reek.")
    
    doc3 = Doc.new
    file = "#{here}/tmp/docs/monkey_stink"
    doc3.add_field("filename", file, :index => false)
    doc3.add_field("contents", java.io.FileReader.new(file))
    
    IndexWriter.open(@store, @analyzer, true) do |writer|
      writer.add_documents([doc1, doc2, doc3])
    end
    
    reader = IndexReader.open(@store)
    terms = reader.terms.map { |term| term.text }
    terms.sort.should == %w{ donkeys stink like monkeys frequently snakes just reek }.sort
    reader.close
  end
  
  it "endows Document::Document with an all-at-once #create" do
    docs = []
    docs << Doc.create([
      ["filename", "donkey_stink", {:index => false}], 
      ["contents", "Donkeys stink like monkeys."]
    ])
    
    file = "#{here}/tmp/docs/monkey_stink"
    docs << Doc.create([
      ["filename", file, {:index => false}],
      ["contents", java.io.FileReader.new(file)]
    ])
    IndexWriter.open(@store, @analyzer, true) do |writer|
      writer.add_documents(docs)
    end
    
    reader = IndexReader.open(@store)
    terms = reader.terms.map { |term| term.text }
    terms.sort.should == %w{ donkeys frequently stink like monkeys }.sort
    reader.close
  end

  it "can search in the usual, plodding Lucene way" do
    IndexWriter.open(@store, @analyzer, true) do |writer|
      writer.add_documents(@documents)
    end
    IndexSearcher.open(@store) do |searcher|
      parser = Parser.new("contents", @analyzer)
      query = parser.parse("monkeys")
      top_docs = searcher.search(query, 10)
      top_docs.size.should == 2
    
      term = Term.new("contents", "frequently")
      hits = searcher.search(TermQuery.new(term))
      hits.size.should == 1
      docs = hits.to_a
      docs.first.get("filename").should == "#{here}/tmp/docs/monkey_stink"
    end
  end

  
end
