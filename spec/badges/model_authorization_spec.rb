require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../model_spec_helper'

describe Badges::ModelAuthorization do

  before(:each) do 
    engine.storage.roles =  { 'anonymous' =>['view'],
                'member'    =>['can create a new project'],
                'admin'     =>['can update projects'] }
                
    engine.storage.by_roles = {
      '1' => [{:role=>'admin'}, {:role=>'member'}],
      '2' => [{:role=>'admin', :on=>{:class=>'Account', :id=>1}}, {:role=>'member'}],
      '3' => [{:role=>'admin', :on=>{:class=>'Account'}}, {:role=>'member'}],
      '4' => [{:role=>'admin'}]
    }

    engine.storage.on_roles = {
      '1' => [{:role=>'admin', :by=>{:class=>'User', :id=>2}}]
    }
  end

  it "should prevent create without correct privilege" do
    Badges::TestProject.class_eval do
      privilege_required 'can create a new project'=>:create
    end
    
    Badges.thread_current_user = User.new(4)
    lambda { Badges::TestProject.create(:name=>'this should fail') }.should raise_error(SecurityError)
  end

  # it "privilege_required_succeeds" do
  #   tu = Badges::TestUser.create(:username =>'tu')
  #   r = Badges::Role.create(:name=>'foo')
  #   p = Badges::Privilege.create(:name=>"can create project")
  #   rp = Badges::RolePrivilege.create(:role=>r, :privilege=>p)
  #   tu.grant_role('foo')
  #   Thread.current['current_user'] = tu
  #   sp = Badges::TestProject.create(:name=>'this should work')
  #   assert !sp.new_record?
  # end
  # 
  # it "on_and_user_options" do
  #   tu1 = Badges::TestUser.create(:username =>'tu1')
  #   r1 = Badges::Role.create(:name=>'foo')
  #   p1 = Badges::Privilege.create(:name=>"can create project")
  #   rp1 = Badges::RolePrivilege.create(:role=>r1, :privilege=>p1)
  #   Thread.current['current_user'] = tu1
  #   tu1.grant_role('foo')
  # 
  #   #grant the role on a different project for a different user
  #   sp2 = Badges::TestProject.create(:name=>'this should also work')
  #   tu2 = Badges::TestUser.create(:username =>'tu2')
  #   r2 = Badges::Role.create(:name=>'bar')
  #   p2 = Badges::Privilege.create(:name=>"can update project")
  #   rp2 = Badges::RolePrivilege.create(:role=>r2, :privilege=>p2)
  #   tu2.grant_role('bar', sp2)
  # 
  #   sp1 = Badges::TestProject.create(:name=>'this should work')
  #   
  #   #ok, now try to update w.o role, and it won't work
  #   sp1.owner = tu1
  #   sp1.peer = sp1
  #   sp1.name = 'a new name'
  #   assert_raise SecurityError do
  #     sp1.save!
  #   end
  # 
  #   
  #   # puts r2.privileges.inspect
  #   # puts tu2.privileges(sp2).inspect
  #   # puts tu2.user_roles.inspect
  # 
  #   sp1.owner = tu1
  #   sp1.peer = sp1
  #   sp1.name = 'a new name'
  #   assert_raise SecurityError do
  #     sp1.save!
  #   end
  # 
  #   #now use the right authorizable and user
  #   sp1.owner = tu2
  #   sp1.peer = sp2
  #   sp1.name = 'another name'
  #   assert_nothing_raised do
  #     sp1.save!
  #   end
  # 
  # end
  # 
  # it "find_protected" do
  #   tu = Badges::TestUser.create(:username =>'tu')
  #   Thread.current['current_user'] = tu
  # 
  #   #test the various ways to call find
  #   assert_raise SecurityError do
  #     Badges::TestProject.find(:all)
  #   end
  # 
  #   assert_raise SecurityError do
  #     Badges::TestProject.find(:first)
  #   end
  # 
  #   assert_raise SecurityError do
  #     Badges::TestProject.find(1)
  #   end
  # 
  #   assert_raise SecurityError do
  #     Badges::TestProject.find_by_name('some name')
  #   end
  # 
  #   assert_raise SecurityError do
  #     Badges::TestProject.find_all_by_name('some name')
  #   end
  # 
  #   assert_raise SecurityError do
  #     Badges::TestProject.find_or_create_by_name('some name')
  #   end
  # 
  #   assert_raise SecurityError do
  #     Badges::TestProject.find_by_sql('select * from badges_test_projects')
  #   end
  # 
  # end
  # 
  # it "authorization_checker" do
  #   tu = Badges::TestUser.create(:username =>'tu')
  #   r = Badges::Role.create(:name=>'foo')
  #   p = Badges::Privilege.create(:name=>"can create project")
  #   rp = Badges::RolePrivilege.create(:role=>r, :privilege=>p)
  #   tu.grant_role('foo')
  # 
  #   Thread.current['current_user'] = tu
  #   sp = Badges::TestProject.new(:name=>'not saving, wont trigger the callback')
  #   ac = Badges::ModelAuthorization::AuthorizationChecker.new
  #   ac.add_to_required_privileges(:before_create, 'can create project', {})
  #   assert ac.callback_check_model_privilege(:before_create, sp)
  # end

end

