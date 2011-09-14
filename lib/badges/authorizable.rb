module Badges
  module Authorizable
    
    def self.included(base) # :nodoc:
      base.extend ClassMethods
    end
    
    module ClassMethods
      
      def authorizable
        include Badges::Authorizable::InstanceMethods
        
        singleton_class.class_eval do
          def accepts_privilege?(privilege, authorized=nil)
            authorized ||= (current_user || Anonymous.instance)
            authorized.has_privilege?(privilege, self)
          end
        end
        
      end
      
    end
    
    module InstanceMethods

      # this is the list of user roles on this instance
      def authorizations
        engine.authorizations_on(self)
      end
      # alias :user_roles :roles
      
      def authorizeds(authorized_class, privilege=nil)
        engine.authorizeds(self, authorized_class, privilege)
      end
      # alias :users :authorized
      
      def accepts_privilege?(privilege, authorized=nil)
        authorized ||= (current_user || Anonymous.instance)
        authorized.has_privilege?(privilege, self)
      end
      
      def role_granted(role_name, authorized)
        authorized.grant_role(role_name, self)
      end
      
      def role_revoked(role_name, authorized)
        authorized.revoke_role(role_name, self)
      end
      
      def members_by_role
        authorizations.inject({}) do |groups, auth|
          groups[auth.role] = [] if groups[auth.role].nil?
          groups[auth.role] << auth.by
          groups
        end
      end

      def members(role=nil)
        result = unless role
          authorizations.collect{|auth| auth.by}
        else
          authorizations.inject([]){|l, auth| l << auth.by if (auth.role == role) }
        end
        result.uniq
      end
      
      def engine
        Badges::AuthorizationEngine.instance
      end

    end
  end
end

