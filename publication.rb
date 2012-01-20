require 'sinatra'
require 'json'

post '/pull' do
  require './sudoku_generator'
  config = JSON.parse(params[:config])
  config['difficulty'] = "easy" if config['test']
  @puzzle_out = SudokuGenerator.new(config['difficulty'].to_sym).generate.split(%r{\s*}).each_slice(3).to_a
  erb :puzzle
end

post '/validate_config' do
  content_type :json
  response = {}
  response[:errors] = []
  config = JSON.parse(params[:config])
  if ["easy", "medium", "hard"].include?(config['difficulty'])
    response[:valid] = true
  else
    response[:valid] = false
    response[:errors] << "Difficulty must be easy, medium or hard"
  end
  response.to_json
end