module Badges
  module Authorized
    
    def self.included(base) # :nodoc:
      base.extend ClassMethods
    end

    module ClassMethods

      def authorized
        include Badges::Authorized::InstanceMethods
      end

    end

    module InstanceMethods
      
      # return list of roles, and what they are on
      def authorizations
        engine.authorizations_by(self)
      end

      def authorizables(authorizable_class, privilege=nil)
        engine.authorizables(self, authorizable_class, privilege)
      end

      def grant_role(role_symbol, authorizable=nil)
        engine.grant_role(role_symbol, self, authorizable)
      end
      
      def revoke_role(role_symbol, authorizable=nil)
        engine.revoke_role(role_symbol, self, authorizable)
      end

      def has_privilege?(privilege, authorizable=nil)
        engine.has_privilege?(privilege, self, authorizable)
      end
      alias :can? :has_privilege?

      def roles_on(authorizable=nil)
        engine.authorized_roles(self).inject([]) do |result, user_role|
          if (is_user_role_on_all?(user_role, authorizable) ||
              is_user_role_on_class?(user_role, authorizable) ||
              is_user_role_on_instance?(user_role, authorizable))
            
            result << user_role[:role].to_sym
            
          end
          result
        end
      end

      # check if authorized has the role on this (instance, class, or nil/global) authorizable
      def has_role?(role_symbol, authorizable=nil)
        self.roles_on(authorizable).include?(role_symbol.to_sym)
      end

      # private
      
      def is_user_role_on_all?(user_role, authorizable=nil)
        authorizable.nil? && !user_role[:on]
      end
      
      def is_user_role_on_class?(user_role, authorizable=nil)
        authorizable && authorizable.is_a?(Class) &&
        user_role[:on] && user_role[:on][:class] &&
        (user_role[:on][:class] == authorizable.name) &&
        user_role[:on][:id].nil?
      end

      def is_user_role_on_instance?(user_role, authorizable=nil)
        authorizable && !authorizable.is_a?(Class) &&
        user_role[:on] && user_role[:on][:class] &&
        (user_role[:on][:class] == authorizable.class.name) &&
        user_role[:on][:id] && (user_role[:on][:id] == authorizable.id)
      end

      def engine
        Badges::AuthorizationEngine.instance
      end

    end

  end
end
