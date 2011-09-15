require File.dirname(__FILE__) + '/../spec_helper'

require 'action_controller'
require 'action_view'
ActionView::Template::Handlers::ERB::ENCODING_FLAG = ActionView::ENCODING_FLAG
require 'rspec/rails'

module TestApp
  class Application < Rails::Application
    config.encoding = "utf-8"
    config.filter_parameters += [:password]
    config.active_support.deprecation = :stdout
  end
end

TestApp::Application.initialize!

require 'application_controller'

module Badges
  
  class TestAuthorizationController < ApplicationController

    def self._routes
      Rails.application.routes
    end

    include Badges::ControllerAuthorization

    privilege_required ['can test','really can test'], :only => [:index]
    privilege_required 'can test class', :on=>Account, :only => [:get_class]
    privilege_required 'can test param', :on=>Account, :param=>:id, :only => [:get_param]

    @test_account = nil

    def get_test_account
      @test_account
    end

    def test_account=(tp)
      @test_account = tp
    end
    
    def unauthorized
      render :test=>'unauthorized!'
    end

    def index
      render :text=>"index"
    end

    def get_class
      render :text=>"class"
    end

    def get_param
      render :text=>"param"
    end

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
    
    def rescue_action(e) 
      raise e 
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
                'member'    =>['view','edit'],
                'admin'     =>['view','edit','delete','can test','really can test', 'can test class'] }
                
    engine.storage.by_roles = {
      '1' => [{:role=>'member'}],
      '2' => [{:role=>'admin'}],
      '3' => [{:role=>'admin', :on=>{:class=>'Account'}}]
    }

    engine.storage.on_roles = {
      '1' => [{:role=>'admin', :by=>{:class=>'User', :id=>2}}]
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
  
end

#   def test_privilege_required_authorizable_class
#     tu = Badges::TestUser.create(:username =>'tu')
#     r = Badges::Role.create(:name=>'class tester')
#     p = Badges::Privilege.create(:name=>'can test class')
#     rp = Badges::RolePrivilege.create(:role=>r, :privilege=>p)
# 
#     @controller.current_user = tu
#     get :get_class
#     assert_not_equal "class", @response.body
#     assert_response :redirect
# 
#     # once we grant the role, now this should work
#     tu.grant_role 'class tester', Account
#     
#     get :get_class
#     assert_equal "class", @response.body
#     assert_response :success
#   end
#   
#   def test_privilege_required_authorizable_param
#     tu = Badges::TestUser.create(:username =>'tu')
#     r = Badges::Role.create(:name=>'param tester')
#     p = Badges::Privilege.create(:name=>'can test param')
#     rp = Badges::RolePrivilege.create(:role=>r, :privilege=>p)
#     tp = Account.create(:name=>'test authorizable param')
# 
#     @controller.current_user = tu
#     get :get_param, :id=>tp.id
#     assert_not_equal "param", @response.body
#     assert_response :redirect
# 
#     # once we grant the role, now this should work
#     tu.grant_role 'param tester', tp
#     assert tp.accepts_privilege?('can test param', tu)
#     
#     get :get_param, :id=>tp.id
#     assert_equal "param", @response.body
#     assert_response :success
#   end
#   
#   def test_privilege_required_authorizable_variable
#     tu = Badges::TestUser.create(:username =>'tu')
#     r = Badges::Role.create(:name=>'variable tester')
#     p = Badges::Privilege.create(:name=>'can test variable')
#     rp = Badges::RolePrivilege.create(:role=>r, :privilege=>p)
#     tp = Account.create(:name=>'test authorizable variable')
# 
#     @controller.current_user = tu
#     @controller.test_account = tp
#     get :get_variable
#     assert_not_equal "variable", @response.body
#     assert_response :redirect
# 
#     # once we grant the role, now this should work
#     tu.grant_role 'variable tester', tp
#     assert tp.accepts_privilege?('can test variable', tu)
#     
#     get :get_variable
#     assert_equal "variable", @response.body
#     assert_response :success
#   end
# 
#   def test_privilege_required_authorizable_method
#     tu = Badges::TestUser.create(:username =>'tu')
#     r = Badges::Role.create(:name=>'method tester')
#     p = Badges::Privilege.create(:name=>'can test method')
#     rp = Badges::RolePrivilege.create(:role=>r, :privilege=>p)
#     tp = Account.create(:name=>'test authorizable method')
# 
#     @controller.current_user = tu
#     @controller.test_account = tp
#     get :get_method
#     assert_not_equal "method", @response.body
#     assert_response :redirect
# 
#     # once we grant the role, now this should work
#     tu.grant_role 'method tester', tp
#     assert tp.accepts_privilege?('can test method', tu)
#     
#     get :get_method
#     assert_equal "method", @response.body
#     assert_response :success
#   end
# 
#   def test_privilege_required_authorizable_object
#     tu = Badges::TestUser.create(:username =>'tu')
#     r = Badges::Role.create(:name=>'object tester')
#     p = Badges::Privilege.create(:name=>'can test object')
#     rp = Badges::RolePrivilege.create(:role=>r, :privilege=>p)
#     tp = Account.create(:name=>'test authorizable object')
# 
#     @controller.current_user = tu
#     @controller.test_account = tp
#     get :get_object
#     assert_not_equal "object", @response.body
#     assert_response :redirect
# 
#     # once we grant the role, now this should work
#     tu.grant_role 'object tester', tp
#     assert tp.accepts_privilege?('can test object', tu)
#     
#     get :get_object
#     assert_equal "object", @response.body
#     assert_response :success
#   end
# 
# end
