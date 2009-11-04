require "#{here = File.dirname(__FILE__)}/../helpers.rb"

include Lucene
# include Lucene::Analysis
# include Lucene::Index
# include Lucene::QueryParser
# include Lucene::Search
# include Lucene::Store
include Lucene::Document

describe "Document" do
  
  before do
    # @store = RAMDirectory.new
    # @analyzer = StandardAnalyzer.new
    @doc = Doc.new
    @doc.add_field("title", "McLintock!")
  end
  
  it "knows its field names" do
    @doc.field_names.should == ["title"]
  end
  
  it "has an adder for analyzed fields" do
    @doc.analyzed("type", "movie")
    @doc.field_names.should == ["title", "type"]
  end
  
  it "has an adder for stored fields" do
    @doc.stored("type", "movie")
    @doc.field_names.should == ["title", "type"]
  end
  
end