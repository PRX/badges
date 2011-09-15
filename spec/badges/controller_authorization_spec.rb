require File.dirname(__FILE__) + '/../spec_helper'

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

require 'application_controller'

module Badges
  
  class TestAuthorizationController < ApplicationController

    def rescue_action(e); raise e; end

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

describe Badges::TestAuthorizationController, {:type => :controller} do
  
  before(:all) do
    Rails.application.routes.draw do
      namespace :badges do
        resources :test_authorization do
          collection do
            get :unauthorized, :get_class, :get_param, :get_variable, :get_method, :get_object
          end
        end
      end
    end

    Badges::Configuration.unauthorized_url = { :controller => '/badges/test_authorization', :action => 'unauthorized' }
  end

  before(:each) do 
    engine.storage.roles =  { 'anonymous' =>['view'],
                'member'    =>['view'],
                'admin'     =>['can test','really can test','can test class','can test param','can test variable','can test method','can test object'] }
                
    engine.storage.by_roles = {
      '1' => [{:role=>'member'}],
      '2' => [{:role=>'admin'}],
      '3' => [{:role=>'admin', :on=>{:class=>'Account'}}],
      '4' => [{:role=>'admin', :on=>{:class=>'Account', :id=>1}}]
    }

    engine.storage.on_roles = {
      '1' => [{:role=>'admin', :by=>{:class=>'User', :id=>4}}]
    }
  end

  it "can protect actions from anonymous user" do
    controller.current_user = nil
    get :index
    response.should be_redirect
    response.should redirect_to(Badges::Configuration.unauthorized_url)
  end

  it "can protect actions from user with no authorization" do
    controller.current_user = User.new(1)
    get :index
    response.should be_redirect
    response.should redirect_to(Badges::Configuration.unauthorized_url)
  end

  it "can allow actions from user with authorization" do
    controller.current_user = User.new(2)
    get :index
    response.should_not be_redirect
    response.body.should == "index"
  end

  it "can protect actions from user with no authorization on a class" do
    controller.current_user = User.new(1)
    get :get_class
    response.should be_redirect
    response.should redirect_to(Badges::Configuration.unauthorized_url)
  end

  it "can allow actions from user with authorization on a class" do
    controller.current_user = User.new(3)
    get :get_class
    response.should_not be_redirect
    response.body.should == "class"
  end


  it "can allow actions from user with authorization on an instance specified by a param" do
    controller.current_user = User.new(4)
    get :get_param, :id=>1
    response.should_not be_redirect
    response.body.should == "param"
  end

  it "can protect actions from user with authorization on wrong instance specified by a param" do
    controller.current_user = User.new(4)
    get :get_param, :id=>2
    response.should be_redirect
    response.should redirect_to(Badges::Configuration.unauthorized_url)
  end
  
  it "can allow actions from user with authorization on a variable" do
    controller.current_user = User.new(4)
    controller.set_test_account(Account.new(1))
    get :get_variable
    response.should_not be_redirect
    response.body.should == "variable"
  end

  it "can protect actions from user with no authorization on variable" do
    controller.current_user = User.new(4)
    controller.set_test_account(Account.new(2))
    get :get_variable
    response.should be_redirect
    response.should redirect_to(Badges::Configuration.unauthorized_url)
  end

  it "can allow actions from user with authorization on a method result" do
    controller.current_user = User.new(4)
    controller.set_test_account(Account.new(1))
    get :get_method
    response.should_not be_redirect
    response.body.should == "method"
  end

  it "can protect actions from user with no authorization on a method result" do
    controller.current_user = User.new(4)
    controller.set_test_account(Account.new(2))
    get :get_method
    response.should be_redirect
    response.should redirect_to(Badges::Configuration.unauthorized_url)
  end

  it "can allow actions from user with authorization on a local variable" do
    controller.current_user = User.new(4)
    controller.set_test_account(Account.new(1))
    get :get_object
    response.should_not be_redirect
    response.body.should == "object"
  end

  it "can protect actions from user with no authorization on a local variable" do
    controller.current_user = User.new(4)
    controller.set_test_account(Account.new(2))
    get :get_object
    response.should be_redirect
    response.should redirect_to(Badges::Configuration.unauthorized_url)
  end

end
