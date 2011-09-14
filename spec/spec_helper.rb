require "rubygems"

require 'spec'
require 'spec/autorun'

require 'active_support'
require 'action_pack'
require 'action_controller'
require 'action_view'

$: << (File.dirname(__FILE__) + "/../lib")
require "badges"

Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}


Spec::Runner.configure do |config|
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  # config.use_transactional_fixtures = true
  # config.use_instantiated_fixtures  = false
  # config.fixture_path = RAILS_ROOT + '/spec/fixtures/'

  # == Fixtures
  #
  # You can declare fixtures for each example_group like this:
  #   describe "...." do
  #     fixtures :table_a, :table_b
  #
  # Alternatively, if you prefer to declare them only once, you can
  # do so right here. Just uncomment the next line and replace the fixture
  # names with your fixtures.
  #
  # config.global_fixtures = :table_a, :table_b
  #
  # If you declare global fixtures, be aware that they will be declared
  # for all of your examples, even those that don't use them.
  #
  # You can also declare which fixtures to use (for example fixtures for test/fixtures):
  #
  # config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  #
  # == Mock Framework
  #
  # RSpec uses its own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  #
  # == Notes
  #
  # For more information take a look at Spec::Runner::Configuration and Spec::Runner
end


Badges::Configuration.define do |config| 
  config.storage = :test
  config.anonymous_role = :anonymous
end

class TestModel
  attr_accessor :id
  include Badges::Authorized
  include Badges::Authorizable

  def initialize(id=nil)
    @id = id
  end
  
  def ==(b)
    return false unless b
    # puts "compare: #{self.class.name}_#{@id} == #{b.class.name}_#{b.id}"
    @id == b.id
  end
  
  def self.find ids
    ids.collect{|i| self.new(i)}
  end
  
end

class User < TestModel
  authorized
end

class Account < TestModel
  authorizable
end

def engine
  Badges::AuthorizationEngine.instance
end
