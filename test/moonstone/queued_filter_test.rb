require File.join(File.dirname(__FILE__), "/../helpers.rb")

include Lucene
include Lucene::Analysis
include Lucene::Index
include Lucene::QueryParser
include Lucene::Search
include Lucene::Store
include Lucene::Document

describe "Moonstone::QueuedFilter" do

  before do
    @filter_class = Class.new(Moonstone::QueuedFilter)
    @input = WhitespaceTokenizer.new(java.io.StringReader.new("three blind mice"))
  end

  it "may simply define #process(token)" do
    test_filter = Class.new(@filter_class) do
      def process(text)
        if text == 'three'
          ['three', '3']
        else
          text
        end
      end
    end
    stream = test_filter.new(@input)
    stream.map { |t| t.term_text }.should == %w{ three 3 blind mice}
  end
end
