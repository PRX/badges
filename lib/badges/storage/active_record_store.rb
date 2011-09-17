# load the roles, privileges, and uers/role mappings from these hard coded values
require 'active_support'
require 'active_record'

require 'badges/storage/abstract'
require 'badges/storage/active_record/base'
require 'badges/storage/active_record/privilege'
require 'badges/storage/active_record/role_privilege'
require 'badges/storage/active_record/role'
require 'badges/storage/active_record/authorization'

module Badges
  module Storage
    
    class ActiveRecordStore < Abstract
      
      include Badges::Storage::ActiveRecord
      
      AuthorizationClass = Badges::Storage::ActiveRecord::Authorization
      
      def initialize(options={})
        super
      end
      
      def roles
        Role.all.collect{|r| r.name} || []
      end

      def add_role(name)
        return false if name.blank?
        Role.find_or_create_by_name(name)
        true
      rescue
        false
      end

      def delete_role(name)
        Role.destroy_all(["name = ?", name])
        true
      rescue
        false
      end
      
      def privileges(role=nil)
        privileges = if role.nil?
          Privilege.all
        else
          role = Role.find_by_name(role)
          role.privileges if role
        end
        Array(privileges).collect{|r| r.name}
      end

      def add_privilege(name, role=nil)
        return false if name.blank?
        privilege = Privilege.find_or_create_by_name(name)
        if role
          role = Role.find_or_create_by_name(role)
          role.role_privileges.create(:privilege=>privilege)
        end
        true
      rescue
        false
      end
      
      def delete_privilege(name, role=nil)
        if role.nil?
          Privilege.destroy_all(["name = ?", name])
        else
          role = Role.find_by_name(role)
          privilege = Privilege.find_by_name(name)
          if role && privilege
            role_privileges = role.role_privileges.find_by_privilege_id(privilege.id) || []
            Array(role_privileges).each{|rp| rp.destroy}
          end
        end
        true
      rescue
        false
      end
      
      def grant_role(role_symbol, authorized, authorizable=nil)
        attributes_hash = authorization_hash(role_symbol, authorized, authorizable)
        auths = AuthorizationClass.find(:all, :conditions=>attributes_hash)
        AuthorizationClass.create(attributes_hash) if auths.blank?
        true
      rescue
        false
      end
      
      def revoke_role(role_symbol, authorized, authorizable=nil)
        attributes_hash = authorization_hash(role_symbol, authorized, authorizable)
        auths = AuthorizationClass.find(:all, :conditions=>attributes_hash)
        Array(auths).each{|a| a.destroy}
      rescue
        false
      end

      def find_authorized_roles(authorized)
        auths = AuthorizationClass.find(:all, :conditions=>{:authorized_id=>authorized.badges_id}) || []
        auths.collect do |auth|
          role = {:role => auth.role.name.to_s}
          role[:on] = {:class=>auth.authorizable_class} if auth.authorizable_class
          role[:on][:id] = auth.authorizable_id if auth.authorizable_id
          role
        end
      end
      
      def find_authorizable_roles(authorizable)
        auths = AuthorizationClass.find(:all, :conditions=>{:authorizable_class=>authorizable.badges_class_name, 
                                                            :authorizable_id=>authorizable.badges_id}) || []
        auths.collect do |auth|
          {:role=>auth.role.name.to_s, :by=>{:class=>auth.authorized_class, :id=>auth.authorized_id}}
        end
      end
      

      private
      
      def authorization_hash(role_name, authorized, authorizable)
        role = Role.find_or_create_by_name(role_name)
        authorizable_class = authorizable.badges_class_name if authorizable
        authorizable_id = authorizable.badges_id if (authorizable && !authorizable.is_a?(Class))
        
        { :role_id            => role.id,
          :authorized_class   => authorized.badges_class_name,
          :authorized_id      => authorized.badges_id,
          :authorizable_class => authorizable_class,
          :authorizable_id    => authorizable_id }
      end
      

    end
  end
end
