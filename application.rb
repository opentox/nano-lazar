require 'qsar-report'
require 'rdiscount'
require File.join './npo.rb'
$ambit_search = "http://data.enanomapper.net/substance?type=name&search="

include OpenTox

# collect nanoparticles from training dataset (Au + Ag)
dataset = Dataset.find_by(:name=> "Protein Corona Fingerprinting Predicts the Cellular Interaction of Gold and Silver Nanoparticles")
$nanoparticles = dataset.nanoparticles
$coating_list = $nanoparticles.collect{|n| n if !n.coating[0].smiles.nil?}.compact.uniq

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
  prediction_model = OpenTox::Model::Validation.find(params[:id])
  if prediction_model
    model = prediction_model.model
		model_type = "regression"
    report = QMRFReport.new
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
    report.change_catalog :authors_catalog, :modelauthor, {:name => "Christoph Helma", :affiliation => "in silico toxicology gmbh", :contact => "Rastatterstrasse 41, CH-4057 Basel, Switzerland", :email => "helma@in-silico.ch", :number => "1", :url => "http://in-silico.ch"}
    report.ref_catalog :model_authors, :authors_catalog, :modelauthor
    report.value "model_date", "#{Time.parse(model.created_at.to_s).strftime('%Y')}"
    report.change_catalog :publications_catalog, :publications_catalog_1, {:title => "Helma, Rautenberg and Gebele (2013), Validation of read across predictions for nanoparticle toxicities ", :url => "in preparation"}
    report.ref_catalog :references, :publications_catalog, :publications_catalog_1
    report.value "model_species", prediction_model.species
    report.change_catalog :endpoints_catalog, :endpoints_catalog_1, {:name => prediction_model.endpoint, :group => ""}
    report.ref_catalog :model_endpoint, :endpoints_catalog, :endpoints_catalog_1
    report.value "endpoint_units", "#{prediction_model.unit}"
    report.value "algorithm_type", "#{model.class.to_s.gsub('Model::Lazar','')}"
    #TODO add updated algorithms
		#report.change_catalog :algorithms_catalog, :algorithms_catalog_1, {:definition => "see Helma 2016 and lazar.in-silico.ch, submitted version: #{lazar_commit}", :description => "Neighbor algorithm: #{model.neighbor_algorithm.gsub('_',' ').titleize}#{(model.neighbor_algorithm_parameters[:min_sim] ? ' with similarity > ' + model.neighbor_algorithm_parameters[:min_sim].to_s : '')}"}
		#report.ref_catalog :algorithm_explicit, :algorithms_catalog, :algorithms_catalog_1
		#report.change_catalog :algorithms_catalog, :algorithms_catalog_3, {:definition => "see Helma 2016 and lazar.in-silico.ch, submitted version: #{lazar_commit}", :description => "modified k-nearest neighbor #{model_type}"}
		#report.ref_catalog :algorithm_explicit, :algorithms_catalog, :algorithms_catalog_3
		#if model.prediction_algorithm_parameters
		#	pred_algorithm_params = (model.prediction_algorithm_parameters[:method] == "rf" ? "random forest" : model.prediction_algorithm_parameters[:method])
		#end
		#report.change_catalog :algorithms_catalog, :algorithms_catalog_2, {:definition => "see Helma 2016 and lazar.in-silico.ch, submitted version: #{lazar_commit}", :description => "Prediction algorithm: #{model.prediction_algorithm.gsub('Algorithm::','').gsub('_',' ').gsub('.', ' with ')} #{(pred_algorithm_params ? pred_algorithm_params : '')}"}
		#report.ref_catalog :algorithm_explicit, :algorithms_catalog, :algorithms_catalog_2

		# Descriptors in the model 4.3
		#if model.neighbor_algorithm_parameters[:type]
		#	report.change_catalog :descriptors_catalog, :descriptors_catalog_1, {:description => "", :name => "#{model.neighbor_algorithm_parameters[:type]}", :publication_ref => "", :units => ""}
		#	report.ref_catalog :algorithms_descriptors, :descriptors_catalog, :descriptors_catalog_1
		#end

		# Descriptor selection 4.4
		#report.value "descriptors_selection", "#{model.feature_selection_algorithm.gsub('_',' ')} #{model.feature_selection_algorithm_parameters.collect{|k,v| k.to_s + ': ' + v.to_s}.join(', ')}" if model.feature_selection_algorithm  
    
    response['Content-Type'] = "application/xml"
    return report.to_xml
  else
    bad_request_error "model with id: #{params[:id]} does not exist."
  end
end
#=end
get '/predict/?' do
  @prediction_models = []
  models = OpenTox::Model::Validation.all
  prediction_models = models.delete_if{|m| m.model.name !~ /\b(Net cell association)\b/}
 
  # sort and collect prediction models
  @prediction_models[0] = prediction_models.find{|m| m.model[:algorithms]["descriptors"]["method"] == "fingerprint"}
  @prediction_models[1] = prediction_models.delete_if{|m| m.model[:algorithms]["descriptors"]["method"] == "fingerprint"}.find{|m| m.model[:algorithms]["descriptors"]["categories"][0] =~ /P-CHEM/}
  @prediction_models[2] = prediction_models.find{|m| m.model[:algorithms]["descriptors"]["categories"][0] == "Proteomics"}

  # define type (fingerprint,physchem,proteomics)
  @prediction_models[0]["type"] = "fingerprint"
  @prediction_models[1]["type"] = "physchem"
  @prediction_models[2]["type"] = "proteomics"
  
  # select relevant features for each model
  @fingerprint_relevant_features = @prediction_models[0].model.substance_ids.collect{|id| Substance.find(id)}
  fingerprint = $coating_list.sample
  #fingerprint.properties.delete_if{|id,v| !@fingerprint_relevant_features.include?(Feature.find(id))}
  @example_fingerprint = fingerprint
  
  @physchem_relevant_features = @prediction_models[1].model.descriptor_ids.collect{|id, v| Feature.find(id)}
  physchem = $nanoparticles.sample
  # only Ag for testing
  #physchem = $nanoparticles.find{|n| c = Substance.find(n.core_id); c.name == "Ag"}
  physchem.properties.delete_if{|id,v| !@physchem_relevant_features.include?(Feature.find(id))}
  @example_physchem = physchem
  
  @proteomics_relevant_features = @prediction_models[2].model.descriptor_ids.collect{|id, v| Feature.find(id)}
  proteomics = $nanoparticles.sample
  proteomics.properties.delete_if{|id,v| !@proteomics_relevant_features.include?(Feature.find(id))}
  @example_proteomics = proteomics
  

  haml :predict
end

get '/license' do
  @license = RDiscount.new(File.read("LICENSE.md")).to_html
  haml :license, :layout => false
end

post '/predict/?' do
  # select the prediction model
  prediction_model = OpenTox::Model::Validation.find(params[:prediction_model])
  size = params[:size].to_i
  @type = params[:type]

  example_core = params[:example_core]
  example_coating = params.collect{|k,v| v if k =~ /example_coating_/}.compact
  
  input_core = params[:input_core]
  input_coating = params.collect{|k,v| v if k =~ /input_coating_/}.compact

  example_pc = eval(params[:example_pc])
  input_pc = {}
  if @type =~ /physchem|proteomics/
    (1..size).each{|i| input_pc["#{params["input_key_#{i}"]}"] = [params["input_value_#{i}"].to_f] unless params["input_value_#{i}"].blank?}
  end
  
  if @type == "fingerprint"
    # search for database hit
    dbhit = $coating_list.find{|nano| nano.core.name == input_core && (nano.coating.collect{|co| co.name}) == input_coating }
    if !dbhit.nil?
      @match = true
      nanoparticle = dbhit
      @nanoparticle = dbhit
      @name = @nanoparticle.name
    else
      # no database hit => create nanoparticle
      nanoparticle = Nanoparticle.new
      nanoparticle.core_id = Compound.find_by(:name=>input_core).id.to_s
      input_coating.each{|ic| nanoparticle.coating_ids << Compound.find_by(:name=>ic).id.to_s}
      @match = false
      @nanoparticle = nanoparticle
    end
  end

  if @type =~ /physchem|proteomics/
    (@type == "physchem") ? (@physchem_relevant_features = input_pc.collect{|id,v| Feature.find(id)}.compact) : (@physchem_relevant_features = [])
    (@type == "proteomics") ? (@proteomics_relevant_features = input_pc.collect{|id,v| Feature.find(id)}.compact) : (@proteomics_relevant_features = [])
    
    if input_pc == example_pc && input_core == example_core #&& input_coating == example_coating
      # unchanged input = database hit
      nanoparticle = Nanoparticle.find_by(:id => params[:example_id])
      nanoparticle.properties = input_pc
      @match = true
      @nanoparticle = nanoparticle
      @name = nanoparticle.name
    else
      # changed input = create nanoparticle to predict
      nanoparticle = Nanoparticle.new
      nanoparticle.core_id = Compound.find_by(:name=>input_core).id.to_s
      #nanoparticle.coating_ids = [Compound.find_by(:name=>input_coating).id.to_s] if input_coating
      nanoparticle.properties = input_pc
      @match = false
      @nanoparticle = nanoparticle
    end
  end


  # prediction output
  @input = input_pc
  @prediction = prediction_model.model.predict nanoparticle
  haml :prediction
end
