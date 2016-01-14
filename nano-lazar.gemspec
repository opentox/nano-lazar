# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "lazar"
  s.version     = File.read("./VERSION").strip
  s.authors     = ["Christoph Helma, Micha Rautenberg, David Vorgrimmler, Denis Gebele"]
  s.email       = ["helma@in-silico.ch"]
  s.homepage    = "http://github.com/opentox/nano-lazar"
  s.summary     = %q{Lazar nanotoxicity framework}
  s.description = %q{Libraries for nanoparticle lazy structure-activity relationships and read-across.}
  s.license     = 'GPL-3'

  s.rubyforge_project = "lazar"
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_runtime_dependency "bundler"
  s.add_runtime_dependency "lazar"
end
