require './publication'  # <-- your sinatra app
require 'rspec'
require 'rack/test'
require 'json'
set :environment, :test

describe 'Daily Puzzle Publication' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  describe "pulling a new puzzle" do
    it "should generate soemthing that looks like a puzzle" do
      post '/pull', :config => {:difficulty => "easy"}.to_json
      last_response.should be_ok
      last_response.body.scan("<td>").length.should == 81
    end
  end
end
