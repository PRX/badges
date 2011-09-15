require File.dirname(__FILE__) + '/../spec_helper'

describe Badges::Authorization do
  
  it "create with role, on, and by" do
    auth = Badges::Authorization.new(:admin, User.new(1), Account.new(1))
    auth.should_not be_nil
    auth.by.should == User.new(1)
    auth.authorized.should == User.new(1)

    auth.on.should == Account.new(1)
    auth.authorizable.should == Account.new(1)
  end

  it "checks equality on role, on, and by" do
    auth1 = Badges::Authorization.new(:admin, User.new(1), Account.new(1))
    auth2 = Badges::Authorization.new('admin', User.new(1), Account.new(1))
    auth1.should == auth2
    auth2.role = :member
    auth1.should_not == auth2
  end
  
end

