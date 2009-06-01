require File.join(File.dirname(__FILE__), "/../helpers.rb")

include Lucene
include Lucene::Analysis
include Lucene::Index
include Lucene::QueryParser
include Lucene::Search
include Lucene::Store
include Lucene::Document

describe "Moonstone::Analyzer" do
  
  it "initializes with a list of classes" do
    @analyzer = Moonstone::Analyzer.new WhitespaceTokenizer, LowerCaseFilter
    @analyzer.tokenize("name", "Joe's Bait Shopper").should == %w{ joe's bait shopper }
  end
  
  it "can initialize with classes and args" do
    @analyzer = Moonstone::Analyzer.new WhitespaceTokenizer, [LengthFilter, 4, 6]
    @analyzer.tokenize("name", "I am not very happy unless reading").should == %w{ very happy unless}
  end
  
end

describe "Moonstone::MultiAnalyzer" do
  
  it "initializes with a list of classes" do
    field_chains = {}
    field_chains[:name] = [ KeywordTokenizer, LowerCaseFilter ]
    field_chains[:categories] = [ WhitespaceTokenizer, LowerCaseFilter ]
    @analyzer = Moonstone::MultiAnalyzer.new(field_chains)
    @analyzer.tokenize("name", "All Together Now").should == ["all together now"]
    @analyzer.tokenize("categories", "All Together Now").should == ["all", "together", "now"]
  end
  

end