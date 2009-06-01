require File.join(File.dirname(__FILE__), "/../helpers.rb")

include Lucene
include Lucene::Analysis
include Lucene::Index
include Lucene::QueryParser
include Lucene::Search
include Lucene::Store
include Lucene::Document

describe "A subclass of Moonstone::Engine" do
  before do
    @store = RAMDirectory.new
    @analyzer = StandardAnalyzer.new
    docs = [Doc.new, Doc.new]
    docs[0].add_field "name", "Shakey's Pizza", :term_vector => :with_positions_offsets
    docs[0].add_field "description", "Pizza and a video game arcade", :term_vector => :with_positions_offsets
    docs[1].add_field "name", "Ikea", :term_vector => :with_positions_offsets
    docs[1].add_field "description", "You have to build the pizza yourself", :term_vector => :with_positions_offsets
    IndexWriter.open(@store, @analyzer, true) do |writer|
      writer.add_documents(docs)
    end
    
    @class = Class.new(Moonstone::Engine) do
      def doc_from(record)
        Doc.create(record)
      end
      
      def create_query(string)
        token = string.split(" ").first.downcase
        TermQuery.new(Term.new("description", token))
      end
      
      def analyzer
        Lucene::Analysis::StandardAnalyzer.new
      end
      
    end
    
    @engine = @class.new(:store => @store, :inspect => true)
    @results = @engine.search("Pizza Hut")
    @result = @results.first
  end

  after do
    @store.close
  end
  
  it "initializes with an options hash" do
    engine = @class.new
    engine.store.class.should == RAMDirectory
    
    engine = @class.new(:store => "path/to/directory")
    engine.store.should == "path/to/directory"
    
    store = RAMDirectory.new
    engine = @class.new(:store => store)
    engine.store.class.should == RAMDirectory

  end
  
  it "can index a collection of records" do
    doc1 = [["name", "Burger King"], ["description", "Fast food"]]
    doc2 = [["name", "Depeche Mode"], ["description", "Fast fashion"]]
    @engine.index([doc1, doc2])
    @engine.reader do |r|
      r.terms.for_field('name').sort.should == %w{ shakey pizza ikea burger king depeche mode }.sort
    end
  end
  
  it "can do a basic search" do
    results = @engine.search("Pizza Hut")
    results.should.respond_to? :each
    results.size.should == 2
  end
  
  it "can search with a limit" do
    results = @engine.search("Pizza Hut", :limit => 1)
    results.size.should == 1
  end
  
  it "search returns an Enumerable results set" do
    @results.class.included_modules.should include Enumerable
    @results.should.respond_to? :each
  end
  
  it "contains the total hits count" do
    results = @engine.search("Pizza Hut", :limit => 1)
    results.size.should == 1
    results.totalHits.should == 2
  end
  
  it "search takes a block" do
    r = []
    @engine.search("Pizza Hut") do |doc|
      r << doc.get('name')
    end
    r.sort.should == ["Ikea", "Shakey's Pizza"].sort
  end
  
  it "should populate a tokens hash in the doc (with inspect == true)" do
    @result.tokens.nil?.should be_false
    ["shakey", "pizza"].each { |token| @result.tokens['name'].include?(token).should == true }
    ["pizza", "video", "game"].each { |token| @result.tokens['description'].include?(token).should == true }
  end
  
  describe "an individual result" do
    
    it "is a Document" do
      @result.class.should == Document
    end
    
    it "provides the document score" do
      @result.score.class.should == Float
    end
    
  end

  it "can search with a filter and limit"
  it "can search with a filter, limit and sort"
  
  describe "incremental updates" do
    
    before do
      #Add some docs to play with
      docs = [
          [["id", "1234"], ["name", "pizza place"], ["description", "a generic pizza place - 1234"]],
          [["id", "2345"], ["name", "another pizza place"], ["description", "another generic pizza place - 2345"]],
          [["id", "3456"], ["name", "yet another pizza place"], ["description", "yet another generic pizza place - 3456"]]
        ]
      @engine.insert_documents(docs)
      @engine.search("generic").length.should == 3
    end
    
    after do
      docs = [
          {:field => "id", :value => "1234"},
          {:field => "id", :value => "2345"},
          {:field => "id", :value => "3456"}
        ]
      @engine.delete_documents(docs)
      @engine.search("generic").length.should == 0
    end
    
    it "can update an existing record" do
      doc = [
              ["id", "1234"],
              ["name", "pizza place"],
              ["description", "the first generic pizza place - 1234"]
            ]
      @engine.update_document(:field => "id", :value => "1234", :document => doc)
      results = @engine.search("1234")
      results.length.should == 1
      result = results.first
      result['name'].should == "pizza place"
      result['description'].should == "the first generic pizza place - 1234"
    end
    
    it "can update multiple records at the same time" do
      documents = [
                    {
                      :field => "id",
                      :value => "1234",
                      :document => [
                                      ["id", "1234"],
                                      ["name", "pizza place"],
                                      ["description", "a generic pizza place - 1234-a"]
                                    ]
                      },
                      {
                        :field => "id",
                        :value => "2345",
                        :document => [
                                        ["id", "2345"],
                                        ["name", "another pizza place"],
                                        ["description", "another generic pizza place - 2345-a"]
                                      ]
                        },
                        {
                          :field => "id",
                          :value => "3456",
                          :document => [
                                          ["id", "3456"],
                                          ["name", "yet another pizza place"],
                                          ["description", "yet another generic pizza place - 3456-a"]
                                        ]
                          }
                  ]
      @engine.update_documents(documents)
      results = @engine.search("generic")
      results.length.should == 3
      results.each do |result|
        result["description"].include?("#{result['id']}-a").should == true
      end
    end
    
    it "can add and delete a record" do
      doc = [["id", "4567"], ["name", "Temp Pizza Place"], ["description", "This is just a doc to be deleted"]]
      @engine.insert_document(doc)
      @engine.search("deleted").length.should == 1
      @engine.delete_document(:field => "id", :value => "4567")
      @engine.search("deleted").length.should == 0
    end
    
  end
  
end