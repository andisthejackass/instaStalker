$:.unshift File.expand_path("../", __FILE__)
require 'rubygems'
require 'sinatra'
require './instaStalker'
run Sinatra::Application
