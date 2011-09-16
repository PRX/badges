ENV['RAILS_ENV']='test'

require "rubygems"
require 'bundler/setup'
require 'active_support'

require 'rspec'
require 'rspec/autorun'

$: << (File.dirname(__FILE__) + "/../lib")
require "badges"

Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}

RSpec.configure do |config|
  # config.mock_with :mocha
  config.mock_with :rspec
end

Badges::Configuration.define do |config| 
  config.storage = :test
  config.anonymous_role = :anonymous
end

def engine
  Badges::AuthorizationEngine.instance
end
