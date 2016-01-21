require_relative "../nanoparticles.rb"
data = JSON.parse(File.read("./data.json"))
relevant_features = JSON.parse(File.read("./relevant-features.json"))
example = data[data.keys.sample]["physchem"].select{|f,v| relevant_features.keys.include? f}
#data.collect
puts predict(example)[:match].collect{|id,v| v["tox"]}.first
puts predict(example)[:prediction]
#puts predict(example)[:neighbors].size

