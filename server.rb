require 'sinatra'

get '/hi' do
  load 'script.rb'
  @imagemap = Imagemap.new
  erb :index
end