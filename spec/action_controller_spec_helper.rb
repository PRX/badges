require 'action_controller'
require 'action_view'
ActionView::Template::Handlers::ERB::ENCODING_FLAG = ActionView::ENCODING_FLAG
require 'rspec/rails'

module TestApp
  class Application < Rails::Application
    config.logger = Logger.new(STDOUT)
    config.active_support.deprecation = :stderr
  end
end

TestApp::Application.initialize!

module Badges
  
  class TestAuthorizationController < ActionController::Base

    def rescue_action(e); raise e; end

    def current_user; @current_user; end
    def current_user=(user); @current_user = user; end

    def self._routes
      Rails.application.routes
    end

    include Badges::ControllerAuthorization

    privilege_required ['can test','really can test'], :only => [:index]
    privilege_required 'can test class', :on=>Account, :only => [:get_class]
    privilege_required 'can test param', :on=>Account, :param=>:id, :only => [:get_param]

    @test_account = nil
    def get_test_account; @test_account; end
    def set_test_account(tp); @test_account = tp; end
    
    def unauthorized; render :test=>'unauthorized!'; end
    def index; render :text=>"index"; end
    def get_class; render :text=>"class"; end
    def get_param; render :text=>"param"; end

    def get_variable
      privilege_required 'can test variable', :on=>:test_account do
        render :text=>"variable"
      end
    end

    def get_method
      privilege_required 'can test method', :on=>:get_test_account do
        render :text=>"method"
      end
    end

    def get_object
      aaccount = get_test_account
      privilege_required 'can test object', :on=>aaccount do
        render :text=>"object"
      end
    end

  end
end

TestApp::Application.routes.draw do
  namespace :badges do
    resources :test_authorization do
      collection do
        get :unauthorized, :get_class, :get_param, :get_variable, :get_method, :get_object
      end
    end
  end
end

Badges::Configuration.unauthorized_url = { :controller => '/badges/test_authorization', :action => 'unauthorized' }
