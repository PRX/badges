require 'active_support'

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
    if ids.is_a?(Array)
      ids.collect{|i| self.new(i)}
    else
      self.new(ids)
    end
  end
  
end

class User < TestModel
  authorized
  authorizable
end

class Account < TestModel
  authorizable  
  attr_accessor :owner
end