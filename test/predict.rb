require_relative "../nanoparticles.rb"
data = JSON.parse(File.read("./data.json"))
query_features = JSON.parse(File.read("./query-features.json"))
key = data.keys.sample
p key
example = data[key]["physchem"].select{|f,v| query_features.include? f}
prediction = predict(example)
puts prediction[:match].collect{|id,v| v["tox"]}.first
puts prediction[:prediction]
puts prediction[:neighbors].size

