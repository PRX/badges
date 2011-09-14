require 'singleton'
require 'authorized'

module Badges
  class Anonymous

    include Singleton
    include Badges::Authorized

    authorized

    def roles
      engine.anonymous_roles
    end
    
    def grant_role(role_symbol, authorizable=nil)
      nil
    end
    
    def revoke_role(role_symbol, authorizable=nil)
      nil
    end

    def has_privilege?(privilege, authorizable=nil)
      engine.has_privilege?(privilege, nil, authorizable)
    end
    alias :can? :has_privilege?

    def authorizables(authorizable_class, privilege=nil)
      []
    end

  end
end
