module Badges
  module Storage
    class Abstract

      def initialize(options={})
        @options = options
      end

      def find_roles
      end
      
      def find_user_roles(user_id=nil)
      end

    end
  end
end
