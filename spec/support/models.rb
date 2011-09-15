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