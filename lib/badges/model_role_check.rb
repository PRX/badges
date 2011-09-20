module Badges
  class ModelRoleCheck
    attr_accessor :role_name, :authorizable_class, :block
    
    def initialize(role_name, authorizable_class, &block)
      @role_name = role_name
      @authorizable_class = authorizable_class
      @block = block 
    end
    
    def pass?(authorized, authorizable)
      if block
        result = block.call(authorized, authorizable)
        # puts "pass? result: #{result}"
        result
      else
        true
      end
    end
    
  end
end