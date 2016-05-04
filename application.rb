require 'json'
require 'rdiscount'
require_relative './nanoparticles.rb'

$ambit_search = "http://data.enanomapper.net/substance?type=name&search="

configure :development do
  $logger = Logger.new(STDOUT)
end

get '/?' do
  redirect to('/predict') 
end

get '/predict/?' do
  data = JSON.parse(File.read("./data.json"))
  query_features = JSON.parse(File.read("./query-features.json"))
  @example = data[data.keys.sample]["physchem"].select{|f,v| query_features.include? f}
  #@json_example = JSON.pretty_generate(@example)
  haml :predict
end

get '/license' do
  @license = RDiscount.new(File.read("LICENSE.md")).to_html
  haml :license, :layout => false
end

post '/predict/?' do
  size = params[:size].to_i
  @input = []
  (1..size).each{|i| @input << [params["input_key_#{i}"], params["input_value_#{i}"].to_f]}
  @params = Hash[*@input.flatten]
  @prediction = predict @params
  haml :prediction
end
