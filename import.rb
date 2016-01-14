require 'json'
require 'yaml'
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
      #component = substance["composition"]#["component"]
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
    nanomaterials << nm
  end
end
puts "Total imported: #{nanomaterials.size}"
puts "With TOX data: #{nanomaterials.select{|n| n.tox}.size}"
puts "With nanoparticle characterisation: #{nanomaterials.select{|n| n.p_chem}.size}"
puts "With TOX data and particle characterisation: #{nanomaterials.select{|n| n.tox and n.p_chem}.size}"
#puts names.sort.uniq.to_yaml
#p nanomaterials.collect{|n| n.uri}.uniq.size
