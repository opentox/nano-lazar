require 'qsar-report'
require 'rdiscount'
$ambit_search = "http://data.enanomapper.net/substance?type=name&search="
$npo_search = "http://bioportal.bioontology.org/search?q=%s&ontologies=NPO&include_properties=false&include_views=false&includeObsolete=false&require_definition=false&exact_match=false&categories="


configure :development do
  #$logger = Logger.new(STDOUT)
end

before do
  @version = File.read("VERSION").chomp
end

get '/?' do
  redirect to('/predict') 
end
#=begin
get '/qmrf-report/:id' do
  prediction_model = OpenTox::Model::NanoPrediction.find(params[:id])
  if prediction_model
    model = prediction_model.model
		model_type = "regression"
    report = OpenTox::QMRFReport.new
		if File.directory?("#{File.dirname(__FILE__)}/../../lazar")
    	lazar_commit = `cd #{File.dirname(__FILE__)}/../../lazar; git rev-parse HEAD`.strip
    	lazar_commit = "https://github.com/opentox/lazar/tree/#{lazar_commit}"
  	else
    	lazar_commit = "https://github.com/opentox/lazar/releases/tag/v#{Gem.loaded_specs["lazar"].version}"
		end
    report.value "QSAR_title", "Model for #{prediction_model.species} #{prediction_model.endpoint}"
    report.change_catalog :software_catalog, :firstsoftware, {:name => "nano-lazar", :description => "nano-lazar toxicity predictions", :number => "1", :url => "https://nano-lazar.in-silico.ch", :contact => "helma@in-silico.ch"}
    report.ref_catalog :QSAR_software, :software_catalog, :firstsoftware
    report.value "qmrf_date", "#{Time.now.strftime('%d %B %Y')}"
    report.change_catalog :authors_catalog, :firstauthor, {:name => "Christoph Helma", :affiliation => "in silico toxicology gmbh", :contact => "Rastatterstrasse 41, CH-4057 Basel, Switzerland", :email => "helma@in-silico.ch", :number => "1", :url => "http://in-silico.ch"}
    report.ref_catalog :qmrf_authors, :authors_catalog, :firstauthor
    report.change_catalog :authors_catalog, :modelauthor, {:name => "Christoph Helma", :affiliation => "in silico toxicology gmbh", :contact => "Contact Address", :email => "Contact Email", :number => "1", :url => "Web Page"}
    report.ref_catalog :model_authors, :authors_catalog, :modelauthor
    report.value "model_date", "#{Time.parse(model.created_at.to_s).strftime('%Y')}"
    report.change_catalog :publications_catalog, :publications_catalog_1, {:title => "Rautenberg, Gebele and Helma (2013), Validation of read across predictions for nanoparticle toxicities ", :url => "in preparation"}
    report.ref_catalog :references, :publications_catalog, :publications_catalog_1
    report.value "model_species", prediction_model.species
    report.change_catalog :endpoints_catalog, :endpoints_catalog_1, {:name => prediction_model.endpoint, :group => ""}
    report.ref_catalog :model_endpoint, :endpoints_catalog, :endpoints_catalog_1
    report.value "endpoint_units", "#{prediction_model.unit}"
    report.value "algorithm_type", "#{model.class.to_s.gsub('OpenTox::Model::Lazar','')}"
    #TODO add more
		report.change_catalog :algorithms_catalog, :algorithms_catalog_1, {:definition => "see Helma 2016 and lazar.in-silico.ch, submitted version: #{lazar_commit}", :description => "Neighbor algorithm: #{model.neighbor_algorithm.gsub('_',' ').titleize}#{(model.neighbor_algorithm_parameters[:min_sim] ? ' with similarity > ' + model.neighbor_algorithm_parameters[:min_sim].to_s : '')}"}
		report.ref_catalog :algorithm_explicit, :algorithms_catalog, :algorithms_catalog_1
		report.change_catalog :algorithms_catalog, :algorithms_catalog_3, {:definition => "see Helma 2016 and lazar.in-silico.ch, submitted version: #{lazar_commit}", :description => "modified k-nearest neighbor #{model_type}"}
		report.ref_catalog :algorithm_explicit, :algorithms_catalog, :algorithms_catalog_3
		if model.prediction_algorithm_parameters
			pred_algorithm_params = (model.prediction_algorithm_parameters[:method] == "rf" ? "random forest" : model.prediction_algorithm_parameters[:method])
		end
		report.change_catalog :algorithms_catalog, :algorithms_catalog_2, {:definition => "see Helma 2016 and lazar.in-silico.ch, submitted version: #{lazar_commit}", :description => "Prediction algorithm: #{model.prediction_algorithm.gsub('OpenTox::Algorithm::','').gsub('_',' ').gsub('.', ' with ')} #{(pred_algorithm_params ? pred_algorithm_params : '')}"}
		report.ref_catalog :algorithm_explicit, :algorithms_catalog, :algorithms_catalog_2

		# Descriptors in the model 4.3
		if model.neighbor_algorithm_parameters[:type]
			report.change_catalog :descriptors_catalog, :descriptors_catalog_1, {:description => "", :name => "#{model.neighbor_algorithm_parameters[:type]}", :publication_ref => "", :units => ""}
			report.ref_catalog :algorithms_descriptors, :descriptors_catalog, :descriptors_catalog_1
		end

		# Descriptor selection 4.4
		report.value "descriptors_selection", "#{model.feature_selection_algorithm.gsub('_',' ')} #{model.feature_selection_algorithm_parameters.collect{|k,v| k.to_s + ': ' + v.to_s}.join(', ')}" if model.feature_selection_algorithm  
    response['Content-Type'] = "application/xml"
    
		return report.to_xml
  else
    bad_request_error "model with id: #{params[:id]} does not exist."
  end
end
#=end
get '/predict/?' do
  @prediction_models = []
  prediction_models = OpenTox::Model::NanoPrediction.all
  prediction_models.each{|m| m.model[:feature_selection_algorithm_parameters]["category"] == "P-CHEM" ? @prediction_models[0] = m : @prediction_models[1] = m}
  # define type (pc or pcp)
  @prediction_models.each_with_index{|m,idx| idx == 0 ? m[:pc_model] = true : m[:pcp_model] = true}
  # collect nanoparticles by training dataset (Ag + Au)
  dataset = OpenTox::Dataset.find_by(:name=> "Protein Corona Fingerprinting Predicts the Cellular Interaction of Gold and Silver Nanoparticles")
  nanoparticles = dataset.nanoparticles
  
  # select physchem_parameters by relevant_features for of each model
  @pc_relevant_features = @prediction_models[0].model.relevant_features.collect{|id, v| OpenTox::Feature.find(id)}
  @pcp_relevant_features = @prediction_models[1].model.relevant_features.collect{|id, v| OpenTox::Feature.find(id)}
  pcp = nanoparticles.sample
  pcp.physchem_descriptors.delete_if{|id,v| !@pcp_relevant_features.include?(OpenTox::Feature.find(id))}
  @example_pcp = pcp
  
  pc = nanoparticles.sample
  pc.physchem_descriptors.delete_if{|id,v| !@pc_relevant_features.include?(OpenTox::Feature.find(id))}
  @example_pc = pc

  haml :predict
end

get '/license' do
  @license = RDiscount.new(File.read("LICENSE.md")).to_html
  haml :license, :layout => false
end

post '/predict/?' do
  # choose the right prediction model
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
  (1..size).each{|i| input_pc["#{params["input_key_#{i}"]}"] = [params["input_value_#{i}"].to_f] unless params["input_value_#{i}"] == "-"}

  
  # define relevant_features by input
  @type = "pc" ? (@pc_relevant_features = input_pc.collect{|id,v| OpenTox::Feature.find(id)}) : (@pc_relevant_features = [])
  @type = "pcp" ? (@pcp_relevant_features = input_pc.collect{|id,v| OpenTox::Feature.find(id)}) : (@pcp_relevant_features = [])

  if input_pc == example_pc && input_core == example_core && input_coating == example_coating
    # unchanged input = database hit
    nanoparticle = OpenTox::Nanoparticle.find_by(:id => params[:example_id])
    nanoparticle.physchem_descriptors = input_pc
    @match = true
    @nanoparticle = nanoparticle
    @name = nanoparticle.name
  else
    # changed input = create nanoparticle to predict
    nanoparticle = OpenTox::Nanoparticle.new
    nanoparticle.core = input_core
    nanoparticle.coating = input_coating
    nanoparticle.physchem_descriptors = input_pc
    @match = false
    @nanoparticle = nanoparticle
  end
  # prediction output
  @input = input_pc
  @prediction = prediction_model.model.predict_substance nanoparticle
  
  haml :prediction
end
