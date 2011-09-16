# load the roles, privileges, and uers/role mappings from these hard coded values
# puts "loading Badges:Storage:Test"
require 'badges/storage/abstract'

module Badges
  module Storage
    class Test < Abstract
      
      attr_writer :roles, :by_roles, :on_roles
      
      def initialize(options)
        super
      end

      def roles
        deep_copy(@roles)
      end

      def add_role(name)
        role = name.to_s
        @roles[role] = [] unless @roles.has_key?(role)
      end

      def delete_role(name)
        role = name.to_s
        @roles.delete(role)
      end

      def privileges
        deep_copy(@privileges)
      end
      
      def add_privilege(privilege, role=nil)
        @privileges << privilege unless @privileges.include?(privilege)
        if role
          @roles[role] << privilege unless @roles[role].include?(privilege)
        end
      end

      def delete_privilege(privilege, role=nil)
        raise "delete_privilege not implemented"
      end

      def grant_role(role_symbol, authorized, authorizable=nil)
        @roles[role_symbol.to_s] = [] unless @roles.has_key?(role_symbol.to_s)
        role = {:role => role_symbol.to_s}
        role[:on] = hash_for(authorizable) if authorizable
        @by_roles[authorized.id.to_s] = [] unless @by_roles.has_key?(authorized.id.to_s)
        @by_roles[authorized.id.to_s] << role
        
        if authorizable && !authorizable.is_a?(Class)
          role = {:role=>role_symbol.to_s}
          role[:by] = hash_for(authorized)
          @on_roles[authorizable.id.to_s] = [] unless @on_roles[authorizable.id.to_s]
          @on_roles[authorizable.id.to_s] << role
        end
        
        true
      end
      
      def revoke_role(role_symbol, authorized, authorizable=nil)
        @by_roles[authorized.id.to_s].delete_if do |user_role|
          (user_role[:role] == role_symbol.to_s) && 
          ( (authorizable.nil? && user_role[:on].nil?) ||
            (authorizable && user_role[:on] && (hash_for(authorizable) == user_role[:on])) )
        end
      end
      
      def find_authorized_roles(authorized)
        deep_copy(@by_roles[authorized.id.to_s]) || []
      end
      
      def find_authorizable_roles(authorizable)
        deep_copy(@on_roles[authorizable.id.to_s]) || []
      end
      
      protected
      
      def by_roles
        deep_copy(@by_roles)
      end
      
      def on_roles
        deep_copy(@on_roles)
      end

      def deep_copy( object )
        Marshal.load( Marshal.dump( object ) )
      end
      
    end # Test
  end # Storage
end # Badges

# puts "Test is loaded" if defined?(Badges::Storage::Test)