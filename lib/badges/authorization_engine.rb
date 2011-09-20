require 'singleton'

module Badges
  class AuthorizationEngine
    
    include Singleton
    
    attr_reader :storage

    def initialize(options={})
      storage_type = options[:storage] || Badges::Configuration.storage || :active_record
      require "badges/storage/#{storage_type}_store"
      storage_class_name = "Badges::Storage::#{storage_type.to_s.camelize}Store"
      storage_class = storage_class_name.constantize
      @storage = storage_class.new(options)
    end
    
    def grant_role(role_symbol, authorized, authorizable=nil)
      return false if role_symbol.to_s == Badges::Configuration.default_user_role.to_s
      @storage.grant_role(role_symbol, authorized, authorizable)
    end

    def revoke_role(role_symbol, authorized, authorizable=nil)
      return false if role_symbol.to_s == Badges::Configuration.default_user_role.to_s
      @storage.revoke_role(role_symbol, authorized, authorizable)
    end
    
    # allow check on nil authorized and on nil on
    # this is the common method called either by authorizable or authorized objects
    def has_privilege?(privilege, authorized=nil, authorizable=nil)
      privilege = privilege.to_s
      add_if_missing(privilege)
      authorized ||= Anonymous.instance
      
      # first check to see if the authorized returns a list of roles on the authorizable
      # this should include the default role, and any additional roles derived from logic in the authorized model
      allowed_roles = role_lookup[privilege] || []
      model_auth_roles = authorized.model_roles_on(authorizable)
      
      # puts "model_auth_roles: #{model_auth_roles.inspect}"
      return true if model_auth_roles.detect{|authorized_role| allowed_roles.include?(authorized_role.to_s)}

      # if not these default and roles defined by the model, then look-up the priv as defined in badges
      privileges = privilege_lookup(authorized)[privilege] || {}
      on = authorizable ? privileges[authorizable_class_name(authorizable)] || [] : []
      
      privileges[:all] || (on.include?(:all) || (authorizable && !authorizable.is_a?(Class) && on.include?(authorizable.id)))
    end
    
    def authorizable_class_name(authorizable)
      authorizable.is_a?(Class) ? authorizable.name : authorizable.class.name
    end
    
    #  return list of Badges:Authoriation instances
    def authorizations_by(authorized)
      roles = replace_instances(authorized_roles(authorized), :on)
      # puts "roles: #{roles.inspect}"
      roles.collect{ |role| Authorization.new(role[:role], authorized, role[:on]) }
    end
    
    def authorizations_on(authorizable)
      return [] unless authorizable
      roles = replace_instances(authorizable_roles(authorizable), :by)
      roles.collect{ |role| Authorization.new(role[:role], role[:by], authorizable) }
    end

    def authorized_roles(authorized)
      if !authorized || authorized.is_a?(Anonymous)
        anonymous_roles
      else
        @storage.find_authorized_roles(authorized)
      end
    end

    # use these for caching, need to abstract this stuff
    def anonymous_roles
      #  should it set authorized to Badges::Anonymous.instance?
      Badges::Configuration.anonymous_role ? [{:role=>Badges::Configuration.anonymous_role}] : []
    end

    def authorizable_roles(authorizable)
      @storage.find_authorizable_roles(authorizable)
    end
    
    def authorizeds(authorizable, authorized_class, privilege=nil)
      ids = authorizable_roles(authorizable).inject([]) do |result, role|
        if (role[:by] && role[:by][:class] && role[:by][:id])
          # puts "authorizeds: role:#{role.inspect}"
          if (role[:by][:class] == authorized_class.name) 
            # puts "authorizeds: class matches"
            if !privilege || (@storage.roles[role[:role].to_s] || []).include?(privilege)
              # puts "authorizeds: priv is nil or compatible"
              result << role[:by][:id]
            end
          end
        end
        result
      end
      ids.uniq!
      # if the class supports find(id), as AR and Mongoid both do. Otherwise, return ids.
      authorized_class.respond_to?(:find) ? authorized_class.find(ids) : ids
    end
    
    def authorizables(authorized, authorizable_class, privilege=nil)
      ids = if privilege
        privileges = privilege_lookup(authorized)[privilege.to_s]
        result = (privileges[authorizable_class.name] || [])
        result.delete(:all)
        result
      else
        authorized_roles(authorized).inject([]) do |result, role|
          if (role[:on] && role[:on][:class] &&
              (role[:on][:class] == authorizable_class.name) &&
              role[:on][:id])
            result << role[:on][:id]
          end
          result
        end
      end
      ids.uniq!
      # if the class supports find(id), as AR and Mongoid both do. Otherwise, return ids.
      authorizable_class.respond_to?(:find) ? authorizable_class.find(ids) : ids
    end
    
    # this should look up in a cache - using just a plain jane memoized attribute for now.
    def privilege_lookup(authorized=nil)
      create_privilege_lookup(authorized)
    end
    
    # this should be the same, just needs to be put in the cache
    def create_privilege_lookup(authorized=nil)
      result = {}
      all_roles = @storage.roles
      self.authorized_roles(authorized).each do |role|

        # puts "create_privilege_lookup:       role: #{role.inspect}"
        # puts "create_privilege_lookup: privileges: #{all_roles[role[:role].to_s].inspect}"

        all_roles[role[:role].to_s].each do |privilege|
          result[privilege] ||= {}
          if role[:on]
            object_class = role[:on][:class]
            object_id    = role[:on][:id] || :all
            result[privilege][object_class] = result[privilege][object_class] ? (result[privilege][object_class] & [object_id]) : [object_id]
          else
            result[privilege][:all] = true
          end
        end
      end
      
      result
    end
    
    def role_lookup
      # this is a wrapper for caching purposes - remind me to do that
      @_role_lookup = create_role_lookup
    end
    
    def create_role_lookup
      result = {}
      @storage.roles.keys.each do |role_name|
        role_privileges = @storage.roles[role_name]
        role_privileges.each do |privilege|
          result[privilege] = [] if result[privilege].nil?
          result[privilege] << role_name
        end
      end
      result
    end

    def replace_instances(roles, key)
      # puts "replace_instances roles:#{roles.inspect}, key:#{key}"
      by_class = roles.inject({}) do |groups, auth|
        
        if auth[key]
          name = auth[key][:class]
          if auth[key][:id]
            id = auth[key][:id]
            groups[name] = {} if groups[name].nil?
            groups[name][id] = [] if groups[name][id].nil?
            groups[name][id] << auth
          else
            auth[key] = name.constantize
          end
        end
        
        groups
      end
      
      # puts "by_class = #{by_class.inspect}"

      by_class.keys.each do |name|
        ids = by_class[name].keys
        klass = name.constantize
        instances = klass.respond_to?(:find) ? Array(klass.find(ids)) : []
        # puts "instances: #{instances.inspect}"
        instances.each{|i| by_class[name][i.id].each{ |a| a[key] = i } }
      end

      roles
    end
    
    def add_if_missing(privilege)
      if Badges::Configuration.create_when_missing && !@storage.privileges.include?(privilege)
        @storage.add_privilege(privilege, Badges::Configuration.default_admin_role) 
      end
    end
    
  end
end
