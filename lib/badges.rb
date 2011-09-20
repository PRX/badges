require 'rubygems'
require 'active_support'
require "badges/version"
require 'badges/railtie'
require 'badges/extensions/kernel'

module Badges

  autoload :Configuration, 'badges/configuration'
  autoload :AuthorizationEngine, 'badges/authorization_engine'
  autoload :Authorizable, 'badges/authorizable'
  autoload :ModelExtensions, 'badges/model_extensions'
  autoload :Authorized, 'badges/authorized'
  autoload :Authorization, 'badges/authorization'
  autoload :ModelRoleCheck, 'badges/model_role_check'
  autoload :Anonymous, 'badges/anonymous'
  autoload :ModelAuthorization, 'badges/model_authorization'
  autoload :ControllerAuthorization, 'badges/controller_authorization'
  
  def self.thread_current_user
    Thread.current['current_user'] || nil
  end

  def self.thread_current_user=(user)
    Thread.current['current_user'] = user
  end
end