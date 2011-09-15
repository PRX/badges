require File.dirname(__FILE__) + '/../spec_helper'

def anonymous
  Badges::Anonymous.instance
end

describe Badges::Anonymous do
  
  before(:each) do 
    engine.storage.roles =  { 'anonymous' =>['view'] }
  end

  it "returns anonymous default role" do
    anonymous.roles.should == [{:role=>:anonymous}]
  end
  
  it "can check anonymous privilege" do
    anonymous.should have_privilege(:view)
    anonymous.should_not have_privilege(:edit)
  end

end

