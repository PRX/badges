begin
  require 'rails'
rescue LoadError=>err
  # puts "No 'rails' gem to require."
end

module Badges
  class RailsInstaller

    def self.install
      require 'badges'
      require 'badges/controller_authorization'
      require 'badges/authorized'
      require 'badges/authorizable'
      require 'badges/model_authorization'

      ActionController::Base.send :include, Badges::ControllerAuthorization
      ActionController::Base.send :before_filter, :propogate_current_user

      if defined?(ActiveRecord::Base)
        ActiveRecord::Base.send :include, Badges::Authorized, Badges::Authorizable, Badges::ModelAuthorization
      end
    end
    
  end
end


if defined?(Rails) && defined?(Rails::Railtie)

  module Badges
    class Railtie < Rails::Railtie
    
      initializer "badges" do
        Badges::RailsInstaller.install
      end
    
    end
  end

else

  # puts "Rails::Railtie not supported; Badges::Railtie not installed."
  Badges::RailsInstaller.install

end