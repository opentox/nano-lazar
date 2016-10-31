# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name        = "nano-lazar"
  s.version     = File.read("./VERSION")
  s.authors     = ["Christoph Helma","Micha Rautenberg","Denis Gebele"]
  s.email       = ["helma@in-silico.ch","rautenberg@in-silico.ch","gebele@in-silico.ch"]
  s.homepage    = "http://github.com/enanomapper/nano-lazar"
  s.summary     = %q{nano-lazar}
  s.description = %q{Graphical user interface for nano-lazar toxicology predictions}
  s.license     = 'GPL-3'
  s.executables = ["nano-lazar-start", "nano-lazar-stop"]
  s.rubyforge_project = "nano-lazar"

  s.files       = `git ls-files`.split("\n")
  s.required_ruby_version = '>= 2.0.0'

  s.add_runtime_dependency "lazar"
  s.add_runtime_dependency "sinatra"
  s.add_runtime_dependency "rdiscount"
  s.add_runtime_dependency "haml"
  s.add_runtime_dependency "unicorn"
  s.add_runtime_dependency "gem-path", "~> 0.6.1", '>= 0.6.1'

  s.post_install_message = %q{
    How to build nano-lazar prediction models described over here: https://github.com/opentox/lazar-public-data .  
    Service commands:
      nano-lazar-start
      nano-lazar-stop
  }
end
