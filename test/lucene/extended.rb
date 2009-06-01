require "#{here = File.dirname(__FILE__)}/../helpers.rb"

include Lucene
include Lucene::Analysis
include Lucene::Index
include Lucene::Search
include Lucene::Store
include Lucene::Document

describe "extended operations using mostly the Lucene wrapper" do
  
  before do
    @store = RAMDirectory.new
    @documents = []
    @documents << Doc.create([
      ["filename", "donkey_stink", {:index => false}], 
      ["contents", "Donkeys stink like monkeys."]
    ])
    @documents << Doc.create([
      ["filename", "snake_stink", {:index => false}], 
      ["contents", "Snakes just reek."]
    ])
  end
  
  after do
    @store.close
  end
  
  it "can use a custom analyzer" do
    my_simple_analyzer = Class.new( Analyzer ) do
      def tokenStream(field_name, reader)        
        stream = LetterTokenizer.new(reader)
        process(stream, filters)
      end
      
      def filters
        [[LowerCaseFilter, []],
          [LengthFilter, [5, 15]]
        ]
      end
      def process(stream, filters)
        if filters.empty?
          stream
        else
          klass, args = filters.shift
          process klass.new(stream, *args), filters
        end
      end
    end
    
    IndexWriter.open(@store, my_simple_analyzer.new, true) do |writer|
      @documents.each { |doc| writer.add_document(doc) }
    end
    
    terms = IndexReader.open(@store).terms.map { |term| term.text }
    terms.sort.should == %w{ donkeys monkeys stink snakes }.sort
  end
  
  it "can use a custom analyzer and filter" do
    composing_class = Class.new( Analyzer ) do
      
      def tokenStream(field_name, reader)        
        stream = self.class.tokenizer.new(reader)
        process(stream, self.class.filters)
      end
      
      def self.add_filter(klass, *args)
        @filters ||= []
        @filters << [klass, args]
      end
      
      def self.tokenizer
        @tokenizer ||= WhitespaceTokenizer
      end
      
      def self.tokenizer=(klass)
        @tokenizer = klass
      end
      
      def self.filters
        @filters ||= []
      end
      
      def process(stream, filters)
        if filters.empty?
          stream
        else
          klass, args = filters.first
          process(klass.new(stream, *args), filters.slice(1..-1))
        end
      end
    end
    
    no_stink = Class.new(TokenFilter) do
      def initialize(stream)
        @stream = stream
      end
      def next
        return nil unless t = @stream.next
        until t.term_text != "stink" do
          t = @stream.next
        end
        t
      end
    end
    
    composing_class.tokenizer = LetterTokenizer
    composing_class.add_filter(LowerCaseFilter)
    composing_class.add_filter(LengthFilter, 5, 14)
    composing_class.add_filter(no_stink)
    
    analyzer = composing_class.new
    IndexWriter.open(@store, analyzer, true) do |writer|
      @documents.each { |doc| writer.add_document(doc) }
    end
    
    terms = IndexReader.open(@store).terms.map { |term| term.text }
    terms.sort.should == %w{ donkeys monkeys snakes }.sort
  end
  
end