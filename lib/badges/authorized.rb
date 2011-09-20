module Badges
  module Authorized
    
    autoload :ModelExtensions, 'badges/model_extensions'

    def self.included(base) # :nodoc:
      base.extend Badges::ModelExtensions::ClassMethods unless (base < Badges::ModelExtensions::ClassMethods)
      base.extend ClassMethods
    end

    module ClassMethods
      
      attr_reader :badges_model_role_checks

      def authorized(options={})
        badges_options.merge!(options)
        @badges_model_role_checks = {}
        include Badges::Authorized::InstanceMethods
      end
      
      # declare that an instance of this authorized will have a role on the authorizable if the block is true
      def has_role(role_name, authorizable_class, &block)
        badges_model_role_checks[authorizable_class.name] = [] if badges_model_role_checks[authorizable_class.name].nil?
        badges_model_role_checks[authorizable_class.name] << Badges::ModelRoleCheck.new(role_name.to_s, authorizable_class, &block)
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

      # return list of roles, and what they are on
      def authorizations_by
        engine.authorizations_by(self)
      end

      def authorizables(authorizable_class, privilege=nil)
        engine.authorizables(self, authorizable_class, privilege)
      end

      def grant_role(role_symbol, authorizable=nil)
        engine.grant_role(role_symbol, self, authorizable)
      end
      
      def revoke_role(role_symbol, authorizable=nil)
        engine.revoke_role(role_symbol, self, authorizable)
      end

      def has_privilege?(privilege, authorizable=nil)
        engine.has_privilege?(privilege, self, authorizable)
      end
      alias :can? :has_privilege?

      def roles_on(authorizable=nil)
        engine.authorized_roles(self).inject([]) do |result, user_role|
          if (is_user_role_on_all?(user_role, authorizable) ||
              is_user_role_on_class?(user_role, authorizable) ||
              is_user_role_on_instance?(user_role, authorizable))
            
            result << user_role[:role].to_sym
            
          end
          result
        end
      end

      # check if authorized has the role on this (instance, class, or nil/global) authorizable
      def has_role?(role_symbol, authorizable=nil)
        self.roles_on(authorizable).include?(role_symbol.to_sym)
      end

      # private
      
      def badges_model_role_checks
        self.class.badges_model_role_checks
      end
      
      def model_roles_on(authorizable)
        return [] unless authorizable
        return [] if authorizable.is_a?(Class)
        
        class_name = if authorizable.respond_to?('badges_class_name')
          authorizable.badges_class_name
        else
          authorizable.class.name
        end
        
        checks = badges_model_role_checks[class_name] || []
        
        # puts "model_roles_on: class_name:#{class_name} checks:#{checks.inspect}"
        roles = checks.inject([]){|r, check|
          if check.pass?(self, authorizable)
            r << check.role_name.to_s
          end
          r
        }
        # puts "model_roles_on: roles: #{roles.inspect}"
        roles.compact.uniq
      end

      def is_user_role_on_all?(user_role, authorizable=nil)
        authorizable.nil? && !user_role[:on]
      end
      
      def is_user_role_on_class?(user_role, authorizable=nil)
        authorizable && authorizable.is_a?(Class) &&
        user_role[:on] && user_role[:on][:class] &&
        (user_role[:on][:class] == authorizable.name) &&
        user_role[:on][:id].nil?
      end

      def is_user_role_on_instance?(user_role, authorizable=nil)
        authorizable && !authorizable.is_a?(Class) &&
        user_role[:on] && user_role[:on][:class] &&
        (user_role[:on][:class] == authorizable.class.name) &&
        user_role[:on][:id] && (user_role[:on][:id] == authorizable.id)
      end

      def engine
        Badges::AuthorizationEngine.instance
      end

    end

  end
end
