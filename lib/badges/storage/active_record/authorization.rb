module Badges
  module Storage
    module ActiveRecord

      class Authorization < Base
        set_table_name "badges_authorization"

        belongs_to :role, :class_name=>"Badges::Storage::ActiveRecord::Role", :foreign_key=>'role_id'
      end

    end
  end
end
