# TODO: missing data for protein corona silver particles
require 'json'
require 'yaml'
require 'csv'
require_relative "lib/nano-lazar.rb"
include OpenTox

def feature_name uri
  f = @features[uri]
  name = f['title']
  annotations = f['annotation'].collect{|a| "#{a['p']}: #{a['o']}"}.uniq.join ", "
  name << " (#{annotations})" unless annotations.empty?
  name << " [#{f['units']}]" if f['units'] and !f['units'].empty?
  name
end

nanomaterials = []
feature_names = {}
@features = {}

["nanowiki.json",  "protein-corona.json", "marina.json"].each do |f|
  bundle = JSON.parse(File.read(File.join("data",f)))
  @features.merge! bundle["feature"]
  bundle["dataEntry"].each do |substance|
    nm = Nanoparticle.new
    nm.uri = substance["compound"]["URI"]
    nm.name = substance["values"]["https://apps.ideaconsult.net/enanomapper/identifier/name"] if substance["values"]
    if substance["composition"]
      nr_cores = substance["composition"].select{|c| c["relation"] == "HAS_CORE"}.size
      puts "#{substance["compound"]["URI"]} has #{nr_cores} cores" if nr_cores !=1
      substance["composition"].each do |composition|
        component = composition["component"]
        if component
          name = component["values"]["https://apps.ideaconsult.net/enanomapper/feature/http%3A%2F%2Fwww.opentox.org%2Fapi%2F1.1%23ChemicalNameDefault"]
          #names << name
          if composition["relation"] == "HAS_CORE"
            nm.core = name
          elsif composition["relation"] == "HAS_COATING"
            nm.coating ||= []
            nm.coating << name
          end
        else
          #puts substance.to_yaml
        end
      end
    else
      #puts substance.to_yaml
    end
    substance["values"].each do |k,v|
      property = nil
      if k.match(/TOX/)
        nm.tox ||= []
        property = "tox"
      elsif k.match(/P-CHEM/)
        nm.p_chem ||= []
        property = "p_chem"
      end
      if property
        v.each do |val|
          if val.keys == ["loValue"]
            nm.tox << {k => val["loValue"]} if property == "tox"
            nm.p_chem << {k => val["loValue"]} if property == "p_chem"
          elsif val.keys == ["loQualifier", "loValue"] and val["loQualifier"] == "mean"
            nm.tox << {k => val["loValue"]} if property == "tox"
            nm.p_chem << {k => val["loValue"]} if property == "p_chem"
          elsif val.keys == ["loQualifier", "loValue", "upQualifier", "upValue" ]
            nm.tox << {k => (val["loValue"]+val["upValue"])/2} if property == "tox"
            nm.p_chem << {k => (val["loValue"]+val["upValue"])/2} if property == "p_chem"
          elsif val.keys == ["loQualifier", "loValue"] and val["loQualifier"] == ">="
          else
          p val
          end
        end
      else
        #p k,v
      end
    end
    nm.tox.uniq! if nm.tox
    nm.p_chem.uniq! if nm.p_chem
    nanomaterials << nm
  end
end

puts "Total imported: #{nanomaterials.size}"
puts "With nanoparticle characterisation: #{nanomaterials.select{|n| n.p_chem}.size}"
modelling_data = nanomaterials.select{|n| n.tox and n.p_chem}
puts "With TOX data: #{nanomaterials.select{|n| n.tox}.size}"
puts "With TOX data and particle characterisation: #{modelling_data.size}"
endpoints = modelling_data.collect{|n| n.tox.collect{|t| t.keys}}.flatten.compact.uniq
puts
puts "Endpoints: #{endpoints.size}"

single_value_endpoints = []
endpoint_values = {}

endpoints.each do |e|
  i = 0
  values = []
  modelling_data.each do |n|
    n.tox.each do |t|
      if t[e]
        i += 1
        values << t[e]
      end
    end
  end
  single_value_endpoints << e if values.uniq.size == 1
  endpoint_values[e] = values.size unless values.uniq.size == 1
end

endpoints -= single_value_endpoints
puts "Endpoints with more than one measurement value: #{endpoints.size}"
endpoint_values.select!{|k,v| v > 10}
puts "Endpoints with more than 10 measurements: #{endpoint_values.size}"
endpoints = endpoint_values.keys
puts
puts endpoint_values.sort{|a,b| b[1] <=> a[1]}.collect{|e,v| "#{feature_names[e]}: #{v}"}.join("\n")

endpoint = "https://apps.ideaconsult.net/enanomapper/property/TOX/UNKNOWN_TOXICITY_SECTION/Log2+transformed/94D664CFE4929A0F400A5AD8CA733B52E049A688/E/3ed642f9-1b42-387a-9966-dea5b91e5f8a"
nanomaterials.select!{|nm| nm.tox and nm.tox.collect{|t| t.keys}.flatten.include? endpoint}
p nanomaterials.size

feature_values = {}
nanomaterials.each do |nm|
  (nm.p_chem + nm.tox).each do |f|
    feature_names[f] = feature_name f # avoid appending annotations/units with each function call, unclear why it happens
    p f unless f.size == 1
    k = f.keys.first
    unless f[k].is_a? String
      feature_values[k] ||= []
      feature_values[k] << f[k]
    end
  end
end

# remove empty values
feature_values.select!{|f,vals| vals.uniq.size > 2}
tox_descriptors = feature_values.select{|f,vals| f.match 'TOX'}.keys
p_chem_descriptors = feature_values.select{|f,vals| f.match 'P-CHEM'}.keys

#puts @features.to_yaml

column_names = ["Nanoparticle"] + p_chem_descriptors.collect{|d| feature_names[d]} + tox_descriptors.collect{|d| feature_names[d]}
table = []
CSV.open(File.join(File.dirname(__FILE__),"data","protein_corona_extract.csv"),"w+") do |csv|
  csv << column_names
  nanomaterials.each do |nm|
    if nm.tox and nm.tox.collect{|t| t.keys}.flatten.include? endpoint
      #table << []
      csv << [nm.name] + p_chem_descriptors.collect{|p| nm.p_chem.collect{|pchem| pchem[p]}.compact.first} + tox_descriptors.collect{|p| nm.p_chem.collect{|pchem| pchem[p]}.compact.first}
    end
  end
end
