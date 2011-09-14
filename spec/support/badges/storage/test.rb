# load the roles, privileges, and uers/role mappings from these hard coded values
# puts "loading Badges:Storage:Test"
module Badges
  module Storage
    class Test < Abstract
      
      attr_writer :roles, :by_roles, :on_roles
      
      def roles
        deep_copy(@roles)
      end
      alias :find_roles :roles

      def by_roles
        deep_copy(@by_roles)
      end
      
      def on_roles
        deep_copy(@on_roles)
      end
      
      def initialize(options)
        super
      end
      
      def grant_role(role_symbol, authorized, authorizable=nil)
        @roles[role_symbol.to_s] = [] unless @roles.has_key?(role_symbol.to_s)
        role = {:role => role_symbol.to_s}
        role[:on] = on_hash(authorizable) if authorizable
        @by_roles[authorized.id.to_s] = [] unless @by_roles.has_key?(authorized.id.to_s)
        @by_roles[authorized.id.to_s] << role
        role
      end
      
      def revoke_role(role_symbol, authorized, authorizable=nil)
        @by_roles[authorized.id.to_s].delete_if do |user_role|
          (user_role[:role] == role_symbol.to_s) && 
          ( (authorizable.nil? && user_role[:on].nil?) ||
            (authorizable && user_role[:on] && (on_hash(authorizable) == user_role[:on])) )
        end
      end
      
      def on_hash(authorizable=nil)
        return {} unless authorizable
        if authorizable.is_a?(Class)
          {:class=>authorizable.name}
        else
          {:class=>authorizable.class.name, :id=>authorizable.id}
        end
      end
      
      def find_authorized_roles(authorized)
        deep_copy(@by_roles[authorized.id.to_s]) || []
      end
      
      def find_authorizable_roles(authorizable)
        deep_copy(@on_roles[authorizable.id.to_s]) || []
      end
      
      def deep_copy( object )
        Marshal.load( Marshal.dump( object ) )
      end
      
    end # Test
  end # Storage
end # Badges

# puts "Test is loaded" if defined?(Badges::Storage::Test)