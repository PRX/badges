module Badges
  class Authorization
    attr_accessor :role, :authorized, :authorizable

    alias :by :authorized
    alias :by= :authorized=

    alias :on  :authorizable
    alias :on= :authorizable=
    
    def initialize(role, authorized=nil, authorizable=nil)
      @role = role
      @authorized = authorized
      @authorizable = authorizable
    end
    
    def ==(a)
      return false unless is_a?(Badges::Authorization)
      (self.by == a.by) && (self.on == a.on) && (self.role == a.role)
    end
    
  end
end