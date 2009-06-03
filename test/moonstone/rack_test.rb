require File.join(File.dirname(__FILE__), "/../helpers.rb")
require 'moonstone/racker'

describe "Moonstone::Racker" do
  
  before do
    @class = Class.new { include Moonstone::Racker }
    @app = @class.new
    @req = Rack::MockRequest.new(@app)
  end
  
  it "dispatches correctly" do
    @app.should_receive(:html_GET_smell).and_return("Smell bad.")
    response = @req.get("/smell.html")
    response.status.should == 200
    response.body.should == "Smell bad."
    
    @app.should_receive(:json_GET_smell).and_return("JSON smell bad.")
    response = @req.get("/smell.json")
    response.status.should == 200
    response.body.should == "JSON smell bad."
  end
  
  it "has a built in search example" do
    @app.should_receive(:search).with("I need stuff", {}).and_return(["Here, have mine.", "Moocher."])
    response = @req.get("/search.html?input=I%20need%20stuff")
    response.body.should == "Here, have mine.\n<br>Moocher."
    
    @app.should_receive(:search).with("Food", {}).and_return(["You can't have any"])
    response = @req.get("/search.json?input=Food")
    response.body.should ==  %q{["You can't have any"]}
    
    @app.should_receive(:search).with("Drink", :limit => 3).and_return(["You can't have any"])
    response = @req.get("/search.json?input=Drink&limit=3")
    response.body.should ==  %q{["You can't have any"]}
    
    @app.should_receive(:search).with("one", {}).and_return(%w{a b})
    @app.should_receive(:search).with("two", {}).and_return(%w{c d})
    @app.should_receive(:search).with("three", {}).and_return([])
    data = JSON.unparse(%w{ one two three })
    response = @req.post("/search.json", :input => data)
    response.body.should == %q([["a","b"],["c","d"],[]])
    response.content_type.should == 'application/json'
  end
  
end