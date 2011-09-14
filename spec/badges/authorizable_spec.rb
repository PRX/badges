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
  
  it "adds methods to authorizable instances" do
    @account = Account.new(1)
    @account.authorizations.should == [Badges::Authorization.new('admin', User.new(2), @account)]
  end
  
  it "has privilege from global role" do
    Account.new.should be_accepts_privilege(:edit, User.new(1))
  end
  
  # it "has privilege from role on object" do
  # end
  # 
  # it "has privilege from role on class" do
  # end
  
end
