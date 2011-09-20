require File.dirname(__FILE__) + '/../spec_helper'


describe Badges::ModelExtensions do
  
  before(:all) do
    
    class Foo < TestModel
      include Badges::ModelExtensions
    end
    
  end
  
  it "adds methods to authorizable class and authorized class" do
    Foo.should respond_to(:badges_id_attribute)
    Foo.should respond_to(:badges_class_name)
    Foo.should respond_to(:badges_find)
    Foo.should respond_to(:badges_options)
  end
  
  it "adds methods to instances" do
    foo = Account.new(1)
    foo.should respond_to(:badges_class_name)
    foo.should respond_to(:badges_id)
  end
  
  it "returns default id attribute" do
    Foo.badges_id_attribute.should eql(:id)
  end
  
  it "returns default class name" do
    Foo.badges_class_name.should eql("Foo")
  end
  
  it "returns default class name" do
    Foo.badges_find([1,2,3]).should == [Foo.new(1), Foo.new(2), Foo.new(3)]
  end
  
end
