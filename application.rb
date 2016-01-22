require 'json'
require_relative './nanoparticles.rb'

configure :development do
  $logger = Logger.new(STDOUT)
end

get '/?' do
  redirect to('/predict') 
end

get '/predict/?' do
  data = JSON.parse(File.read("./data.json"))
  relevant_features = JSON.parse(File.read("./relevant-features.json"))
  @example = data[data.keys.sample]["physchem"].select{|f,v| relevant_features.keys.include? f}
  #@json_example = JSON.pretty_generate(@example)
  haml :predict
end

post '/predict/?' do
  size = params[:size].to_i
  @input = []
  (1..size).each{|i| @input << [params["input_key_#{i}"], params["input_value_#{i}"].to_f]}
  @params = Hash[*@input.flatten]
  @prediction = predict @params
  haml :prediction
end
