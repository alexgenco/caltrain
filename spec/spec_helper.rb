require 'minitest/autorun'
require 'minitest/pride'
require 'mocha'

require File.expand_path('../lib/caltrain', File.dirname(__FILE__))
Dir[File.expand_path('**/*_spec.rb', File.dirname(__FILE__))].each { |f| require f }
