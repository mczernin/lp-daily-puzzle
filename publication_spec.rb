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
  
  describe 'edition' do
    
    before (:each) {
      @sudoku_generator = SudokuGenerator.new
      @sudoku_generator.stub(:generate).and_return(SudokuGenerator::SAMPLE_DATA)
      SudokuGenerator.stub(:new).and_return(@sudoku_generator)
    }
    
    it 'should return html for a pull' do
      get '/edition/?difficulty=easy'
      last_response.should be_ok
      last_response.body.scan("<td>").length.should == 81
    end
    
    it 'should return html for a pull' do
      get '/edition/?difficulty=medium'
      last_response.should be_ok
      last_response.body.scan("<td>").length.should == 81
    end
      
    it 'should return html for a pull' do
      get '/edition/?difficulty=hard'
      last_response.should be_ok
      last_response.body.scan("<td>").length.should == 81
    end
    
    it 'should set an etag that changes every day' do
      date_one = Time.parse('3rd Feb 2001 04:05:06+03:30')
      date_two = Time.parse('4th Feb 2001 05:05:06+03:30')
      date_three = Time.parse('4th Feb 2001 08:10:06+03:30')
      Time.stub(:now).and_return(date_one)
      get '/edition/?difficulty=hard'
      etag_one = last_response.original_headers["ETag"]
      
      Time.stub(:now).and_return(date_two)
      get '/edition/?difficulty=hard'
      etag_two = last_response.original_headers["ETag"]
      
      get '/edition/?difficulty=hard'
      etag_three = last_response.original_headers["ETag"]
      
      Time.stub(:now).and_return(date_three)
      get '/edition/?difficulty=hard'
      etag_four = last_response.original_headers["ETag"]
      
      etag_one.should_not == etag_two
      etag_two.should == etag_three
      etag_four.should == etag_three
    end
    
    it 'should set an etag that changes every for different difficulties' do
     
      get '/edition/?difficulty=hard'
      etag_hard = last_response.original_headers["ETag"]
      
      get '/edition/?difficulty=medium'
      etag_medium = last_response.original_headers["ETag"]
      
      get '/edition/?difficulty=easy'
      etag_easy = last_response.original_headers["ETag"]
      
      
      
      etag_hard.should_not == etag_medium
      etag_medium.should_not == etag_easy
      etag_easy.should_not == etag_hard
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
    end
  
  end

  describe 'get icon' do
  
    it 'should return a png for /icon' do
      get '/icon.png'
      last_response['Content-Type'].should == 'image/png'
    end
    
  end
  
end
