require File.dirname(__FILE__) + '/../spec_helper'

describe Badges::Authorized do

  before(:each) do 
    engine.storage.roles =  { 'anonymous' =>['view'],
                'member'    =>['view','edit'],
                'admin'     =>['view','edit','delete'] }
                
    engine.storage.by_roles = {
      '1' => [{:role=>'admin'}, {:role=>'member'}],
      '2' => [{:role=>'admin', :on=>{:class=>'Account', :id=>1}}, {:role=>'member'}],
      '3' => [{:role=>'admin', :on=>{:class=>'Account'}}, {:role=>'member'}]
    }

    engine.storage.on_roles = {
      '1' => [{:role=>'admin', :by=>{:class=>'User', :id=>2}}]
    }
  end

  it "adds methods to user class" do
    User.should respond_to(:authorized)
  end
  
  it "adds methods to user instances" do
    User.new.should respond_to(:has_privilege?)
  end
  
  it "returns a list of authorizations by the authorized" do
    @user = User.new(2)
    @user.authorizations.should == [Badges::Authorization.new('admin', @user, Account.new(1)), Badges::Authorization.new('member', @user)]
  end
  
  it "grants a role" do
    @user = User.new(4)
    @user.authorizations.should == []
    @user.grant_role(:super_user)
    @user.roles_on.should == ['super_user']
  end
  
  
  it "revokes a role" do
    @user = User.new(1)
    @user.roles_on.should == ['admin', 'member']
    @user.revoke_role('admin')
    @user.roles_on.should == ['member']
  end
  
  it "has privilege from global role" do
    User.new(1).should have_privilege('edit')
  end
  
  it "returns roles" do
    User.new(1).roles_on.should == ['admin', 'member']
    User.new(1).roles_on(Account.new(1)).should == []

    User.new(2).roles_on.should == ['member']
    User.new(2).roles_on(Account.new(1)).should == ['admin']

    User.new(3).roles_on.should == ['member']
    User.new(3).roles_on(Account).should == ['admin']
  end
  

# it "has privilege from role on object" do
# end
# 
# it "has privilege from role on class" do
# end

  it "has role on authorizable" do
    User.new(2).should have_role(:admin, Account.new(1))
  end
  
end
