module Badges
  module Storage
    module ActiveRecord

      class Role < Base
        set_table_name "badges_roles"

        validates_uniqueness_of :name, :case_sensitive => false
    
        has_many :authorizations, :class_name=>'Badges::Storage::ActiveRecord::Authorization'
        has_many :role_privileges, :class_name=>'Badges::Storage::ActiveRecord::RolePrivilege'
        has_many :privileges, :through=>:role_privileges

        # def includes_privilege?(privilege)
        #   !privileges.find_by_name(privilege).nil?
        # end
      end

    end
  end
end