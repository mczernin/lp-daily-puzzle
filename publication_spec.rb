require './publication'  # <-- your sinatra app
require 'rspec'
require 'rack/test'
require 'json'
require './sudoku_generator'
set :environment, :test

describe 'Daily Puzzle Publication' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  describe "pulling a new puzzle" do
    
    it "should generate soemthing that looks like a puzzle" do      
      post '/pull/', :config => {:difficulty => "easy"}.to_json
      last_response.should be_ok
      last_response.body.scan("<td>").length.should == 81
    end
    
  end
  
  
  describe 'posting a validation config' do
    
    it 'should return valid for easy setting' do
      
      post '/validate_config/', :config => {"difficulty" => "easy"}.to_json
      resp = JSON.parse(last_response.body)
      resp["valid"].should == true
    end
    
    it 'should return valid for medium setting' do

      post '/validate_config/', :config => {"difficulty" => "medium"}.to_json
      resp = JSON.parse(last_response.body)
      resp["valid"].should == true
    end
      
    it 'should return valid for hard setting' do

      post '/validate_config/', :config => {"difficulty" => "hard"}.to_json
      resp = JSON.parse(last_response.body)
      resp["valid"].should == true
    end
    
    it 'should return invalid with a message for invalid config' do
      random_key = (0...8).map{65.+(rand(25)).chr}.join.to_sym
      post '/validate_config/', :config => {"difficulty" => rand.to_s}.to_json
      resp = JSON.parse(last_response.body)
      resp["valid"].should == false
      resp["errors"].should == ["Difficulty must be easy, medium or hard"]
    end
    
    it 'should return invalid with a message for invalid config' do
      post '/validate_config/', :config => {}.to_json
      resp = JSON.parse(last_response.body)
      resp["valid"].should == false
      resp["errors"].should == ["No difficulty setting for the puzzle was provided."]
    end
    
    it 'should return invalid with a message for invalid config' do
      post '/validate_config/'
      resp = JSON.parse(last_response.body)
      resp["valid"].should == false
      resp["errors"].should == ["No config was received"]
    end
  
  end
  
  
  describe 'get a sample' do
  
    it 'should return some html for get requests to /sample.html' do
      get '/sample/'
      
      last_response.should be_ok
      last_response.body.scan("<td>").length.should == 81
    end
    
  end
  
  describe 'get meta.json' do

    it 'should return json for meta.json' do
      get '/meta.json'
      last_response["Content-Type"].should == "application/json;charset=utf-8"
      json = JSON.parse(last_response.body)
      json["name"].should_not == nil
      json["description"].should_not == nil
      json["delivered_every"].should_not == nil
      json["content_type"].should_not == nil
    end
  
  end

  describe 'config options' do
    
    it 'should have a config_options.json file which should contail json' do
      get '/config_options.json'
      last_response["Content-Type"].should == "application/json;charset=utf-8"
      json = JSON.parse(last_response.body)
    end
    
  end

  describe 'get icon' do
  
    it 'should return a png for /icon' do
      get '/icon.png'
      last_response['Content-Type'].should == 'image/png'
    end
    
  end
  
end
