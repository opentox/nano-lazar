require 'sinatra'
require "sinatra/reloader" if development?
require_relative 'protein_corona.rb'
also_reload './protein_corona.rb'

get '/?' do
  @data = JSON.parse(File.read("./data.json")).select{|id,features| features["composition"]["Core composition"] == '[Au]'} # Silver has too may missing values
  @example = @data[@data.keys.sample]["physchem"]
  content_type :json
  JSON.pretty_generate(@example)
end

get '/predict/?' do
end

post '/predict/?' do
  @features = params
  @neighbors = neighbors params
  @features[@endpoint_name] = prediction @neighbors
  @prediction = predict params
end
