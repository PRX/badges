begin
  require 'rails'
rescue LoadError=>err
  # puts "No 'rails' gem to require."
end

if defined?(Rails) && defined?(Rails::Railtie)

  module Badges
    class Railtie < Rails::Railtie
    
      initializer "badges" do
        require 'badges'

        ActionController::Base.send :before_filter, :propogate_current_user
        ActionController::Base.send :include, Badges::ControllerAuthorization

        if defined?(ActiveRecord::Base)
          ActiveRecord::Base.send :include, Badges::Authorized, Badges::Authorizable, Badges::ModelAuthorization
        end

      end
    
    end
  end

else

  # puts "Rails::Railtie not supported; Badges::Railtie not installed."

end