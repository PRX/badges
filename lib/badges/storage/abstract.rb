module Badges
  module Storage
    class Abstract

      def initialize(options={})
        @options = options
      end

      def roles
      end
      
      def add_role(name)
      end

      def delete_role(name)
      end

      def privileges(role=nil)
      end
      
      def add_privilege(privilege, role=nil)
      end

      def delete_privilege(privilege, role=nil)
      end

      def grant_role(role_symbol, authorized, authorizable=nil)
      end
      
      def revoke_role(role_symbol, authorized, authorizable=nil)
      end

      def find_authorized_roles(authorized)
      end
      
      def find_authorizable_roles(authorizable)
      end
      
      protected
      
      def hash_for(authorizable=nil)
        return {} unless authorizable
        if authorizable.is_a?(Class)
          {:class=>authorizable.name}
        else
          {:class=>authorizable.class.name, :id=>authorizable.id}
        end
      end
      
    end
  end
end
