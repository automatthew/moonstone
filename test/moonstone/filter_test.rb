require File.join(File.dirname(__FILE__), "/../helpers.rb")

include Lucene
include Lucene::Analysis
include Lucene::Index
include Lucene::QueryParser
include Lucene::Search
include Lucene::Store
include Lucene::Document

describe "A subclass of Moonstone::Filter" do
  
  before do
    @filter_class = Class.new(Moonstone::Filter)
    @input = WhitespaceTokenizer.new(java.io.StringReader.new("three blind mice"))
  end
  
  it "may simply define #process(token)" do
    test_filter = Class.new(Moonstone::Filter) do
      def process(text)
        text.reverse
      end
    end
    stream = test_filter.new(@input)
    stream.map { |t| t.term_text }.should == %w{ eerht dnilb ecim}
  end
  
  it "may use a block at initialization time to define #process" do
    stream = @filter_class.new(@input) { |text| text.reverse }
    stream.map { |t| t.term_text }.should == %w{ eerht dnilb ecim}
  end
  
  it "can drop a token by having #process return an empty string" do
    stream = @filter_class.new(@input) do |text|
      text == "blind" ? "" : text
    end
    stream.map { |t| t.term_text }.should == %w{ three mice }
  end
  
  
end