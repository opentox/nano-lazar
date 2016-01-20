require 'json'
require 'yaml'
require 'csv'
#require_relative "../lazar/lib/lazar.rb"
#include OpenTox

class Object
  def numeric?
    true if Float(self) rescue false
  end
end

def euclidean_distance(a, b)
  sq = a.zip(b).map{|a,b| (a - b) ** 2}
  Math.sqrt(sq.inject(0) {|s,c| s + c})
end

def dot_product(a, b)
  products = a.zip(b).map{|a, b| a * b}
  products.inject(0) {|s,p| s + p}
end

def magnitude(point)
  squares = point.map{|x| x ** 2}
  Math.sqrt(squares.inject(0) {|s, c| s + c})
end

def cosine_similarity(a, b)
  dot_product(a, b) / (magnitude(a) * magnitude(b))
end

#@endpoint = @data.collect{|r| r[5]}

def neighbors query
end

def csv2json
  csv = CSV.read("data/MergedSheets_edit.csv")
  csv.collect!{|row| row[0..36].collect{|c| c.numeric? ? c.to_f : c } }.compact
  feature_names = [
    "ID",
     csv[0][1],
     csv[0][2],
     csv[0][3],
     csv[6][4],
     "#{csv[0][5]} (#{csv[6][5]} [#{csv[11][5]}])", # endpoint
     "#{csv[0][6]} (#{csv[6][6]})", # endpoint
     "#{csv[6][7]} [#{csv[11][7]}]",
     "#{csv[6][8]} [#{csv[11][8]}]",
     "#{csv[6][9]} [#{csv[11][9]}]",
  ]
  (10..10+5*3).step(3) do |i|
    feature_names += [
     "#{csv[6][i]} [#{csv[11][i]}]",
     "#{csv[6][i+1]} #{csv[8][i+1]} [#{csv[11][i+1]}]",
     "#{csv[6][i+2]} #{csv[8][i+2]}",
    ]
  end
  feature_names += [
   "#{csv[6][28]}",
   "#{csv[6][29]} #{csv[8][29]}",
   "#{csv[6][30]} #{csv[8][30]}",
  ]
  (31..34).each do |i|
    feature_names << "#{csv[6][i]} #{csv[8][i]} [#{csv[11][i]}]"
  end
  (35..36).each do |i|
    feature_names << "#{csv[6][i]} #{csv[8][i]} #{csv[10][i]} [#{csv[11][i]}]"
  end
  data = {}
  csv.drop(12).each do |row|
    id = row.first
    data[id] = {}
    row.each_with_index do |col,i|
      if i == 0
        data[id][:composition] = {}
      elsif i < 5
        data[id][:composition][feature_names[i]] = col
      elsif i < 7
        data[id][:tox] ||= {}
        data[id][:tox][feature_names[i]] = col
      else
        data[id][:physchem] ||= {}
        data[id][:physchem][feature_names[i]] = col
      end
    end
  end
  File.open("data.json","w+"){|f| f.puts data.to_json}
  data
end

#puts data.to_yaml
=begin
R.assign "endpoint", endpoint
(0..data[0].size).each do |c|
  if data.collect{|r| r[c]}.uniq.size > 1
    begin
    R.assign "feature", data.collect{|r| r[c]}
    R.eval "r <- cor(-log(endpoint),-log(feature),use='complete')"
    r = R.eval("r").to_ruby
    p "#{c}: #{r}" if r > 0.3 or r < -0.3
    rescue
    end
  end
end


csv[0..13].each do |row|
  row.each_with_index do |col,i|
    features[i] = features[i].to_s+", "+col.to_s
  end
end

puts features.select{|f| f.match(/Mean/)}.to_yaml

  #n+=1
  #p n,row.first unless row.first.match /^[G|S]/
=end
