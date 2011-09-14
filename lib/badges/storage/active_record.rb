# load the roles, privileges, and uers/role mappings from these hard coded values
module Badges
  module Storage
    class ActiveRecord < Abstract
      
      def find_roles
      end

      def grant_role(role_symbol, authorized, authorizable=nil)
        # role = Badges::Role.find_or_create_by_name(role_symbol.to_s)
        # 
        # if authorizable.nil?
        #   self.user_roles.create(:role=>role)
        # elsif authorizable.is_a? Class
        #   self.user_roles.create(:role=>role, :authorizable_type=>authorizable.base_class.to_s)
        # else
        #   self.user_roles.create(:role=>role, :authorizable=>authorizable)
        # end
      end

      def revoke_role(role_symbol, authorized, authorizable=nil)
        # user_role = find_user_role_by_name(role_symbol.to_s, authorizable)
        # user_role.destroy if user_role
        # # self.user_roles(true)
        # true
      end

      def find_authorized_roles(authorized=nil)
      end
      
      
    end
  end
end


# # include this to get access to the current_user in model instances
# include Badges::ModelAuthorization::InstanceMethods
# 
# # set the associations
# has_many :user_roles, :class_name=>'Badges::UserRole', :foreign_key=>'user_id'
# has_many :roles, :through=>:user_roles, :uniq=>true
# 
# #point userrole to the correct user class
# Badges::UserRole.associate_user_class(self)
# 
# # include the instance methods on the user record
# include Badges::Authorized::InstanceMethods
