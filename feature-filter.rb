require 'rserve'
require 'json'
require 'yaml'
require 'csv'

R = Rserve::Connection.new
ENDPOINT = "Cell.association (Net cell association [mL/ug(Mg)])"

def feature_filter
  data = JSON.parse(File.read("./data.json"))
  features = data["G15.AC"]["physchem"].keys
  R.assign "tox", data.collect{|id,cats| cats["tox"][ENDPOINT]}
  filtered_features = {}
  features.each do |feature|
    R.assign "feature", data.collect{|id,cats| cats["physchem"][feature]}
    begin
      #R.eval "cor <- cor.test(-log(tox),-log(feature),use='complete')"
      R.eval "cor <- cor.test(tox,feature,method = 'pearson',use='complete')"
      pvalue = R.eval("cor$p.value").to_ruby
      if pvalue <= 0.05
        r = R.eval("cor$estimate").to_ruby
        filtered_features[feature] = {}
        filtered_features[feature]["pvalue"] = pvalue
        filtered_features[feature]["r"] = r
      end
    rescue
      f = data.collect{|id,cats| cats["physchem"][feature]}
      f = R.eval("feature").to_ruby
      p f.collect{|f| p f; Math.log f}
      p R.eval("log(feature)").to_ruby
    end
  end
  filtered_features.sort{|a,b| a[1]["pvalue"] <=> b[1]["pvalue"]}.to_h
end

puts feature_filter.to_json
