module Badges
  module Storage
    module ActiveRecord

      class Privilege < Base
        set_table_name "badges_privileges"

        validates_uniqueness_of :name, :case_sensitive => false

        has_many :role_privileges, :class_name=>'Badges::Storage::ActiveRecord::RolePrivilege'
        has_many :roles, :through=>:role_privileges
    
        # after_create :add_to_default_admin_role
        #     
        # def add_to_default_admin_role
        #   default_admin_role = Badges::Role.find(:first, :conditions=>{:name=>(Badges::Config.default_admin_role || "").to_s})
        #   Badges::RolePrivilege.create(:role=>default_admin_role, :privilege=>self) if default_admin_role
        # end
      end

    end
  end
end