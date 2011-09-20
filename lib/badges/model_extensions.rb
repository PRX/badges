require 'active_record'

module Badges
  module ModelExtensions

    def self.included(base) # :nodoc:
      base.extend ClassMethods
    end
    
    module ClassMethods
      
      def badges_find(ids)
        if self <= ::ActiveRecord::Base
          Array(self.find(:all, :conditions=>{self.badges_id_attribute=>ids}))
        elsif self.respond_to?(:find)
          Array(self.find(ids))
        else 
          # logger.error 'only active record supported at the moment, sorry.'
          []
        end
      end
      
      def badges_options
        @badges_options ||= {}
      end

      def badges_class_name
        if self.respond_to?('base_class')
          self.base_class.name
        else
          self.name
        end
      end

      def badges_id_attribute
        badges_options[:id_attribute] || :id
      end

    end
    
    module InstanceMethods

      # here are some clever things to override, may need a better way to do this.
      def badges_id
        self.id
      end

      def badges_class_name
        self.class.badges_class_name
      end

    end
    
  end
end

