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
      
      def badges_class_name
        if self.respond_to?('base_class')
          self.base_class.name
        else
          self.name
        end
      end

    end
    
    module InstanceMethods
      
      def badges_id
        self.id
      end

      def badges_class_name
        self.class.badges_class_name
      end

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
          authorizations.collect{|auth| auth.by }
        else
          authorizations.inject([]){|l, auth| l << auth.by if (auth.role.to_sym == role.to_sym) }
        end
        result.uniq
      end
      
      private
      
      def engine
        Badges::AuthorizationEngine.instance
      end

    end
  end
end

