require File.dirname(__FILE__) + '/../spec_helper'

describe Badges::AuthorizationEngine do
  
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

  it "computes privilege lookup hash" do
    engine.create_privilege_lookup(User.new(2)).should == {"edit"=>{:all=>true, "Account"=>[1]}, "delete"=>{"Account"=>[1]}, "view"=>{:all=>true, "Account"=>[1]}}
  end
  
  it "returns roles for authorized object" do
    engine.authorized_roles(User.new(2)).should == [{:role=>'admin', :on=>{:class=>'Account', :id=>1}}, {:role=>'member'}]
  end
  
  it "should return roles for anonymous user" do
    engine.authorized_roles(nil).should == [{:role=>:anonymous}]
    engine.anonymous_roles.should == [{:role=>:anonymous}]
  end

  it "returns roles for an authorizable object" do
    engine.authorizable_roles(Account.new(1)).should == [{:role=>'admin', :by=>{:class=>'User', :id=>2}}]
  end
  
  it "checks a privilege for a user" do
    engine.should have_privilege(:view, User.new(1))
  end

  it "has privilege from role on class" do
    engine.create_privilege_lookup(User.new(3)).should == {"edit"=>{:all=>true, "Account"=>[:all]}, "delete"=>{"Account"=>[:all]}, "view"=>{:all=>true, "Account"=>[:all]}}
    engine.should have_privilege(:delete, User.new(3), Account)
  end
  
  it "returns authorizable ids for user and class" do
    engine.authorizables(User.new(2), Account).should == [Account.new(1)]
  end
  
  it "returns authorizable ids for user, class and privilege" do
    engine.authorizables(User.new(2), Account, :delete).should == [Account.new(1)]
  end
  
  it "returns authorizable objects for user, class w/finder and privilege" do
    Account.class_eval do
      def self.find(id)
        Account.new(1)
      end
    end
    
    engine.authorizables(User.new(2), Account, :delete).should == Account.new(1)
  end
  
  it "grants a new global role" do
    @user = User.new(4)
    @user.authorizations.should == []
    engine.grant_role(:super_user, @user)
    @user.roles_on.should == [:super_user]
  end
  
  it "revokes a new global role" do
    @user = User.new(1)
    @user.roles_on.should == [:admin, :member]
    engine.revoke_role(:admin, @user)
    @user.roles_on.should == [:member]
  end
  
  it "lists authorizations by authorizable" do
    auths = engine.authorizations_by(User.new(2))
    # puts "auths #{auths.inspect}"
    auths.count.should == 2
  end
  
  it "lists authorizations by authorized" do
    auths = engine.authorizations_on(Account.new(1))
    # puts "auths #{auths.inspect}"
    auths.count.should == 1
  end
  

  it "lists class of authorizeds by authorizable" do
    engine.authorizeds(Account.new(1), User).should == [User.new(2)]
  end
  
end
