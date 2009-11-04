require "#{here = File.dirname(__FILE__)}/../helpers.rb"

include Lucene
include Lucene::Analysis
include Lucene::Index
include Lucene::QueryParser
include Lucene::Search
include Lucene::Store
include Lucene::Document

describe "TopDocs" do
  
  before do
    @store = RAMDirectory.new
    @analyzer = StandardAnalyzer.new
    document1 = Doc.new
    document1.add(Field.new("title", "donkey_stink", Field::Store::YES, Field::Index::NO))
    document1.add(Field.new("contents", "Donkeys stink as much as monkeys", 
      Field::Store::YES, Field::Index::ANALYZED))
    document2 = Doc.new
    document2.add(Field.new("title", "monkey_stink", Field::Store::YES, Field::Index::NO))
    document2.add(Field.new("contents", "Monkeys stink worse than snakes", 
      Field::Store::YES, Field::Index::ANALYZED))
    @documents = [document1, document2]
    
    IndexWriter.open(@store, @analyzer, true) do |writer|
      writer.add_documents(@documents)
    end
    @searcher = IndexSearcher.new(@store)
    @parser = Parser.new("contents", @analyzer)
    @query = @parser.parse("monkeys")
    @top_docs = @searcher.search(@query, 10)
  end
  
  it "knows size" do
    @top_docs.size.should == 2
  end
  
  it "can enumerate over the ScoreDocs" do
    @top_docs.map { |sd| sd.class }.should == [ScoreDoc, ScoreDoc]
  end
  
  it "can access ScoreDocs by index" do
    @top_docs[1].doc.should be_a_kind_of Integer
    @top_docs[1].score.should be_a_kind_of Float
  end
  
  it "can iterate over the Documents" do
    titles = []
    @top_docs.each_doc(@searcher) { |d| titles << d['title'] }
    titles.should == ["donkey_stink", "monkey_stink"]
  end
  
  it "can produce an array of Documents" do
    docs = @top_docs.documents(@searcher)
    docs.class.should == Array
    docs.size.should == 2
    docs.map { |d| d['title'] }.should == ["donkey_stink", "monkey_stink"]
  end
  
  it "takes a block when producing Documents" do
    docs = @top_docs.documents(@searcher) { |d| d.analyzed("backtitle", d["title"].reverse) }

    docs.map { |d| d['backtitle'] }.should == ["knits_yeknod", "knits_yeknom"]
  end

end
