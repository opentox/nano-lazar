require 'json'
require 'yaml'
#require_relative "../lazar/lib/lazar.rb"
require_relative "lib/nano-lazar.rb"
include OpenTox

nanomaterials = []
names = []

["nanowiki.json",  "protein-corona.json", "marina.json"].each do |f|
  JSON.parse(File.read(File.join("data",f)))["dataEntry"].each do |substance|
    nm = Nanomaterial.new
    nm.uri = substance["compound"]["URI"]
    if substance["composition"]
      nr_cores = substance["composition"].select{|c| c["relation"] == "HAS_CORE"}.size
      puts "#{substance["compound"]["URI"]} has #{nr_cores} cores" if nr_cores !=1
      substance["composition"].each do |composition|
        component = composition["component"]
        if component
          name = component["values"]["https://apps.ideaconsult.net/enanomapper/feature/http%3A%2F%2Fwww.opentox.org%2Fapi%2F1.1%23ChemicalNameDefault"]
          names << name
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
puts "Endpoints: #{endpoints.size}"

single_value_endpoints = []
endpoint_values = {}

endpoints.each do |e|
  #json = `curl -H "Accept:application/json" "#{e}" 2>/dev/null`
  #f = JSON.parse(json)["feature"]
  #p k unless f.keys.size == 1
  #k = f.keys.first
  #p e
  #p modelling_data.select{|n| n.tox.select{|t| t[e]}}.size
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
  #puts "#{f[k]['title']} [#{f[k]['units']}]: #{i} #{values}"
end

endpoints -= single_value_endpoints
puts "Endpoints with more than one measurement value: #{endpoints.size}"
#endpoint_values.sort{|a,b| b[1] <=> a[1]}
endpoint_values.select!{|k,v| v > 10}
puts "Endpoints with more than 10 measurements: #{endpoint_values.size}"
endpoints = endpoint_values.keys
#puts endpoints.to_yaml
endpoint_values.sort{|a,b| b[1] <=> a[1]}.each do |e,v|
  json = `curl -H "Accept:application/json" "#{e}" 2>/dev/null`
  f = JSON.parse(json)["feature"]
  p k unless f.keys.size == 1
  k = f.keys.first
  p e
  puts "#{f[k]['title']} [#{f[k]['units']}]: #{v} "
end
#puts "Endpoints with more than one value single_value_endpoints.size
#puts names.sort.uniq.to_yaml
#p nanomaterials.collect{|n| n.uri}.uniq.size
