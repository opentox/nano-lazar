require 'sinatra'
require "sinatra/reloader" if development?
require_relative 'nanoparticles.rb'
also_reload './nanoparticles.rb'

get '/?' do
  @data = JSON.parse(File.read("./data.json"))
  @example = @data[@data.keys.sample]["physchem"]
  # create a data entry form with @example as default values
  #content_type :json
  #JSON.pretty_generate(@example)
end

post '/?' do
  @prediction = predict params
  # display prediction with
  # query + prediction (or match if available)
  # neighbors: id, composition, physchem, tox, similarity
  #content_type :json
  #JSON.pretty_generate(@example)
end
