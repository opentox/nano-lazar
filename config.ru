ENV["LAZAR_ENV"] = "development"
SERVICE = "nano-lazar-gui"
require 'bundler'
Bundler.require
require File.expand_path './application.rb'
require "sinatra/reloader" if development?

FileUtils.mkdir_p 'log' unless File.exists?('log')
log = File.new("log/nano-lazar.log", "a")
#$stdout.reopen(log)
#$stderr.reopen(log)

run Sinatra::Application
