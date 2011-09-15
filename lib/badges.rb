require "badges/version"
require 'badges/configuration'
require 'badges/authorization_engine'
require 'badges/authorizable'
require 'badges/authorization'
require 'badges/authorized'
require 'badges/anonymous'
require 'badges/model_authorization'
require 'badges/controller_authorization'
require 'badges/storage/abstract'
require 'badges/extensions/kernel'

# require 'badges/authorize_handler'

# AR adapter
# require 'badges/privilege'
# require 'badges/role'
# require 'badges/role_privilege'
# require 'badges/user_role'
# 
# require 'extensions/routing'
# require 'extensions/kernel'

require 'badges/railtie'

module Badges
  def self.thread_current_user
    Thread.current['current_user'] || nil
  end

  def self.thread_current_user=(user)
    Thread.current['current_user'] = user
  end
end