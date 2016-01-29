require 'sinatra'
require "sinatra/reloader" if development?
require_relative 'nanoparticles.rb'
also_reload './nanoparticles.rb'

get '/?' do
  data = JSON.parse(File.read("./data.json"))
  query_features = JSON.parse(File.read("./query-features.json"))
  @example = data[data.keys.sample]["physchem"].select{|f,v| query_features.include? f}
  # create a data entry form with @example as default values
end

post '/?' do
  @prediction = predict params
  # display prediction with
  # query + prediction (or match if available)
  # neighbors: id, composition, physchem, tox, similarity
end
