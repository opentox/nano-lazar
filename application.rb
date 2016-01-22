require 'sinatra'
require "sinatra/reloader" if development?
require_relative 'nanoparticles.rb'
also_reload './nanoparticles.rb'

get '/?' do
  data = JSON.parse(File.read("./data.json"))
  relevant_features = JSON.parse(File.read("./relevant-features.json"))
  @example = data[data.keys.sample]["physchem"].select{|f,v| relevant_features.keys.include? f}
  # create a data entry form with @example as default values
end

post '/?' do
  @prediction = predict params
  # display prediction with
  # query + prediction (or match if available)
  # neighbors: id, composition, physchem, tox, similarity
end
