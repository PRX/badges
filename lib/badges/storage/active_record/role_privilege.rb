module Badges
  module Storage
    module ActiveRecord

      class RolePrivilege < Base
        set_table_name "badges_role_privileges"
    
        belongs_to :role, :class_name=>'Badges::Storage::ActiveRecord::Role'
        belongs_to :privilege, :class_name=>'Badges::Storage::ActiveRecord::Privilege'
        validates_uniqueness_of :privilege_id, :scope=>:role_id

      end

    end
  end
end