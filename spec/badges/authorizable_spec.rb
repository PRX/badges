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
  
  it "adds methods to authorizable class" do
    Account.should respond_to(:authorizable)
  end
  
  it "adds methods to authorizable instances" do
    Account.new.should respond_to(:accepts_privilege?)
  end
  
  it "gets authorizations for this instance" do
    @account = Account.new(1)
    @account.authorizations.should == [Badges::Authorization.new('admin', User.new(2), @account)]
  end
  
  it "gets authorized folks for this instance" do
    @account = Account.new(1)
    @account.authorizeds(User).should == [User.new(2)]
  end

  it "has privilege from global role" do
    Account.new.should be_accepts_privilege(:edit, User.new(1))
  end
  
  it "grants a role" do
    @account = Account.new(4)
    @user = User.new(4)

    @user.authorizations.should == []

    @account.role_granted(:super_user, @user)

    @user.roles_on(@account).should == ['super_user']
  end
  
  
  it "revokes a role" do
    @account = Account.new(1)
    @user = User.new(2)

    @user.roles_on(@account).should == ['admin']

    @account.role_revoked(:admin, @user)

    @user.roles_on(@account).should == []
  end

  it "returns authorizeds collected by role" do
    @account = Account.new(4)

    @account.role_granted(:admin, User.new(5))
    @account.role_granted(:admin, User.new(6))
    @account.role_granted(:admin, User.new(7))

    @account.role_granted(:member, User.new(8))
    @account.role_granted(:member, User.new(9))
    @account.role_granted(:member, User.new(10))

    @account.members_by_role.should == {:admin=>[User.new(5), User.new(6), User.new(7)], :member=>[User.new(8), User.new(9), User.new(10)]}
    
  end
  
  
  # it "has privilege from role on object" do
  # end
  # 
  # it "has privilege from role on class" do
  # end
  
end
