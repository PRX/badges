require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../action_controller_spec_helper'

describe Badges::TestAuthorizationController, {:type => :controller} do
  
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
