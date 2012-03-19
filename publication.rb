require 'sinatra'
require 'json'
require 'date'

get '/edition/' do
  require './sudoku_generator'
  params['difficulty'] = "easy" if params['test'] || params['difficulty'].nil?
  etag Digest::MD5.hexdigest(params['difficulty']+Time.now.strftime('%d%m%Y'))
  @puzzle_out = SudokuGenerator.new(params['difficulty'].to_sym).generate.split(%r{\s*}).each_slice(9).to_a
  erb :puzzle
end

post '/validate_config/' do
  content_type :json
  response = {}
  response[:errors] = []
  
  if params[:config].nil? 
    response[:valid] = false
    response[:errors] << "No config was received"
  elsif params[:config]['difficulty'].nil?
    response[:valid] = false
    response[:errors] << "No difficulty setting for the puzzle was provided."
    
  else 
  
    config = JSON.parse(params[:config])
  
    if ["easy", "medium", "hard"].include?(config['difficulty'])
      response[:valid] = true
    else
      response[:valid] = false
      response[:errors] << "Difficulty must be easy, medium or hard"
    end
  end
  response.to_json
end

get '/sample/' do
  require './sudoku_generator'
  @puzzle_out = SudokuGenerator::SAMPLE_DATA.split(%r{\s*}).each_slice(9).to_a
  erb :puzzle
end
