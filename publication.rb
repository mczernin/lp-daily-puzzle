require 'sinatra'
require 'json'

post '/pull' do
  require './sudoku_generator'
  config = JSON.parse(params[:config])
  @puzzle_out = SudokuGenerator.new(config['difficulty'].to_sym).generate.split(%r{\s*}).each_slice(3).to_a
  erb :puzzle
end