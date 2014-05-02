require 'sinatra'

get '/hi' do
  load 'script.rb'
  @imagemap = Imagemap.new('25x25star.jpg')
  erb :index
end

