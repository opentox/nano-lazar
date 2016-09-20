require 'rdiscount'
$ambit_search = "http://data.enanomapper.net/substance?type=name&search="

configure :development do
  $logger = Logger.new(STDOUT)
end

before do
  @version = File.read("VERSION").chomp
end

get '/?' do
  redirect to('/predict') 
end

get '/predict/?' do
  @prediction_models = []
  prediction_models = OpenTox::Model::NanoPrediction.all
  prediction_models.each{|m| m.model[:feature_selection_algorithm_parameters]["category"] == "P-CHEM" ? @prediction_models[0] = m : @prediction_models[1] = m}
  @prediction_models.each_with_index{|m,idx| idx == 0 ? m[:pc_model] = true : m[:pcp_model] = true}
  example = OpenTox::Nanoparticle.all.select{|n| n.core["name"] == "Au"}.sample
  @example_pcp = example
  example = OpenTox::Nanoparticle.all.select{|n| n.core["name"] == "Au"}.sample
  example.physchem_descriptors.delete_if{|k,v| feature = OpenTox::Feature.find_by(:id => k); feature.category != "P-CHEM"}
  @example_pc = example

  haml :predict
end

get '/license' do
  @license = RDiscount.new(File.read("LICENSE.md")).to_html
  haml :license, :layout => false
end

post '/predict/?' do
  prediction_model = OpenTox::Model::NanoPrediction.find(params[:prediction_model])
  size = params[:size].to_i
  example_pc = eval(params[:example_pc])
  pc_descriptors = {}
  (1..size).each{|i| pc_descriptors["#{params["input_key_#{i}"]}"] = [params["input_value_#{i}"].to_f]}
  if example_pc == pc_descriptors 
    # unchanged input = database hit
    nanoparticle = OpenTox::Nanoparticle.find_by(:id => params[:example_id])
    nanoparticle.physchem_descriptors = pc_descriptors
  else
    # changed input = create nanoparticle to predict
    nanoparticle = OpenTox::Nanoparticle.new
    nanoparticle.core = eval(params[:core])
    nanoparticle.coating = eval(params[:coating])
    nanoparticle.physchem_descriptors = pc_descriptors
  end
  # output
  @input = pc_descriptors
  @prediction = prediction_model.model.predict_substance nanoparticle
  @match = true,@nanoparticle = nanoparticle,@name = nanoparticle.name if @prediction[:warning] =~ /identical/
  #@prediction[:neighbors].each do |n|
    #puts n
    #puts nano = OpenTox::Nanoparticle.find(n["_id"])
    #puts nano.name
    #puts n["similarity"]
    #puts n["measurements"]
    #puts nano.physchem_descriptors.delete_if{|k,v| feature = OpenTox::Feature.find_by(:id => k); feature.category != "P-CHEM"}.size
  #end

  haml :prediction
end
