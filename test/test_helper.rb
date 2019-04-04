$VERBOSE = nil

require "simplecov"
SimpleCov.start do
  add_filter "/test/"
end
SimpleCov.minimum_coverage 100

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'redcap'
require 'redcap/configuration'

gem 'minitest'
require 'minitest/autorun'
