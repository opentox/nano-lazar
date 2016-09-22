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
  nanoparticles = OpenTox::Nanoparticle.all.select{|n| n.core["name"] == "Au" || n.core["name"] == "Ag"}
  example = nanoparticles.collect{|n| n if n.physchem_descriptors.size > 16}.compact
  pcp = example.sample
  @example_pcp = pcp
  pc = example.sample
  pc.physchem_descriptors.delete_if{|k,v| feature = OpenTox::Feature.find_by(:id => k); feature.category != "P-CHEM"}
  @example_pc = pc

  haml :predict
end

get '/license' do
  @license = RDiscount.new(File.read("LICENSE.md")).to_html
  haml :license, :layout => false
end

post '/predict/?' do
  prediction_model = OpenTox::Model::NanoPrediction.find(params[:prediction_model])
  size = params[:size].to_i
  @type = params[:type]

  example_core = eval(params[:example_core])
  example_coating = eval(params[:example_coating])
  example_pc = eval(params[:example_pc])

  in_core = eval(params[:in_core])
  in_core["name"] = params[:input_core]
  input_core = in_core

  in_coating = eval(params[:in_coating])
  in_coating[0]["name"] = params[:input_coating]
  input_coating = in_coating

  input_pc = {}
  (1..size).each{|i| input_pc["#{params["input_key_#{i}"]}"] = [params["input_value_#{i}"].to_f]}
  if input_pc == example_pc && input_core == example_core && input_coating == example_coating
    # unchanged input = database hit
    nanoparticle = OpenTox::Nanoparticle.find_by(:id => params[:example_id])
    nanoparticle.physchem_descriptors = input_pc
    @match = true,@nanoparticle = nanoparticle,@name = nanoparticle.name
  else
    # changed input = create nanoparticle to predict
    nanoparticle = OpenTox::Nanoparticle.new
    nanoparticle.core = input_core
    nanoparticle.coating = input_coating
    nanoparticle.physchem_descriptors = input_pc
    @match = false
  end
  # output
  @input = input_pc
  @prediction = prediction_model.model.predict_substance nanoparticle

  haml :prediction
end
