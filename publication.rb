require 'sinatra'
require 'json'

pull '/pull/' do
  require './sudoku_generator'
  config = JSON.parse(params[:config])
  
  config['difficulty'] = "easy" if config['test'] || config['difficulty'].nil?
  @puzzle_out = SudokuGenerator.new(config['difficulty'].to_sym).generate.split(%r{\s*}).each_slice(9).to_a
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
