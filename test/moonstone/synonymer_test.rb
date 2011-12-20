require File.join(File.dirname(__FILE__), "/../helpers.rb")

include Lucene
include Lucene::Analysis
include Lucene::Index
include Lucene::QueryParser
include Lucene::Search
include Lucene::Store
include Lucene::Document

describe "Moonstone::Filters::Synonymer" do

  before do
    @input = WhitespaceTokenizer.new(java.io.StringReader.new("three blind mice"))
  end

  it "should handle synonyms in Array form" do
    test_filter = Moonstone::Filters::Synonymer
    stream = test_filter.new(@input, {'mice' => ['mouses']})
    stream.map { |t| t.term_text }.should == %w{ three blind mice mouses}
  end

  it "should handle synonyms in String form" do
    test_filter = Moonstone::Filters::Synonymer
    stream = test_filter.new(@input, {'mice' => 'mouses'})
    stream.map { |t| t.term_text }.should == %w{ three blind mice mouses}
  end

end
