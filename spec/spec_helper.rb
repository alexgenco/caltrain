#require 'minitest/autorun'
#require 'minitest/pride'
require 'rubygems'
gem 'minitest'
require 'minitest/unit'
require 'minitest/spec'
require 'mocha'
require 'timecop'

Minitest::Unit.autorun

require File.expand_path('../lib/caltrain', File.dirname(__FILE__))
Dir[File.expand_path('**/*_spec.rb', File.dirname(__FILE__))].each { |f| require f }
