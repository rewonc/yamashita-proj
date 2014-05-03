require 'sinatra'

get '/hi' do
  load 'script.rb'
  @imagemap = Imagemap.new('17x33multistar.jpg')
  erb :index
end

