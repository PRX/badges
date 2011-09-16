require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/../../active_record_spec_helper'
require File.dirname(__FILE__) + '/../../../lib/badges/storage/active_record_store'

describe Badges::Storage::ActiveRecordStore do

  before(:each) do
    Badges::Storage::ActiveRecord::Role.delete_all
    Badges::Storage::ActiveRecord::Privilege.delete_all
    Badges::Storage::ActiveRecord::RolePrivilege.delete_all
    Badges::Storage::ActiveRecord::Authorization.delete_all

    @ar_store = Badges::Storage::ActiveRecordStore.new
  end
  
  it 'lists roles' do
    Badges::Storage::ActiveRecord::Role.create(:name=>'lists roles')
    @ar_store.roles.should == ['lists roles']
  end

  it 'adds a role' do
    @ar_store.roles.should == []
    @ar_store.add_role('adds a role')
    @ar_store.roles.should == ['adds a role']

    @ar_store.add_role('adds a role')
    @ar_store.roles.should == ['adds a role']
  end

  it 'adds a role, but only once' do
    @ar_store.roles.should == []
    @ar_store.add_role('adds a role')
    @ar_store.add_role('adds a role')
    @ar_store.roles.should == ['adds a role']
  end

  it 'deletes roles' do
    Badges::Storage::ActiveRecord::Role.create(:name=>'deletes roles')
    @ar_store.roles.should == ['deletes roles']
    @ar_store.delete_role('deletes roles')
    @ar_store.roles.should == []
  end

  it 'lists privileges' do
    Badges::Storage::ActiveRecord::Privilege.create(:name=>'lists privileges')
    @ar_store.privileges.should == ['lists privileges']
  end

  it 'lists privileges for a role' do
    role = Badges::Storage::ActiveRecord::Role.create(:name=>'test')
    role.privileges.create(:name=>'lists privileges for a role')
    @ar_store.privileges('test').should == ['lists privileges for a role']
  end

  it 'adds a privilege' do
    @ar_store.privileges.should == []
    @ar_store.add_privilege('lists privileges')
    @ar_store.privileges.should == ['lists privileges']
  end

  it 'adds a privilege to a role' do
    @ar_store.privileges('test').should == []
    @ar_store.add_privilege('adds a privilege to a role', 'test')
    @ar_store.privileges('test').should == ['adds a privilege to a role']
  end

  it 'deletes privileges' do
    Badges::Storage::ActiveRecord::Privilege.create(:name=>'deletes privileges')
    @ar_store.privileges.should == ['deletes privileges']
    @ar_store.delete_privilege('deletes privileges')
    @ar_store.privileges.should == []
  end

  it 'deletes privilege from role' do
    role = Badges::Storage::ActiveRecord::Role.create(:name=>'test')
    role.privileges.create(:name=>'deletes privilege from role')
    @ar_store.privileges('test').should == ['deletes privilege from role']
    @ar_store.delete_privilege('deletes privilege from role', 'test')
    @ar_store.privileges('test').should == []
    @ar_store.privileges.should == ['deletes privilege from role']
  end
  
  it 'grants a role' do
    user = User.new(1)
    @ar_store.grant_role('grants a role', user)
    
    authorization = Badges::Storage::ActiveRecord::Authorization.find_by_authorized_id(1)
    authorization.should_not be_nil
    authorization.authorized_id.should eql('1')
    authorization.role.name.should eql('grants a role')
    authorization.authorizable_class.should be_nil
    authorization.authorizable_id.should be_nil
  end

  it 'grants a role on a class' do
    user = User.new(1)
    @ar_store.grant_role('grants a role on a class', user, Account)

    authorization = Badges::Storage::ActiveRecord::Authorization.find_by_authorized_id(1)
    authorization.should_not be_nil
    authorization.authorized_id.should eql('1')
    authorization.role.name.should eql('grants a role on a class')
    authorization.authorizable_class.should eql('Account')
    authorization.authorizable_id.should be_nil
  end
  
  it 'grants a role on an instance' do
    user = User.new(1)
    account = Account.new(2)
    @ar_store.grant_role('grants a role on an instance', user, account)

    authorization = Badges::Storage::ActiveRecord::Authorization.find_by_authorized_id(1)
    authorization.should_not be_nil
    authorization.authorized_id.should eql('1')
    authorization.role.name.should eql('grants a role on an instance')
    authorization.authorizable_class.should eql('Account')
    authorization.authorizable_id.should eql('2')
  end

  it 'revokes a role' do
    user = User.new(1)
    @ar_store.grant_role('revokes a role', user)
    authorization = Badges::Storage::ActiveRecord::Authorization.find_by_authorized_id(1)
    authorization.should_not be_nil
    @ar_store.revoke_role('revokes a role', user)

    authorization = Badges::Storage::ActiveRecord::Authorization.find_by_authorized_id(1)
    authorization.should be_nil
  end

  it 'revokes a role on a class' do
    user = User.new(1)
    @ar_store.grant_role('revokes a role on a class', user, Account)
    authorization = Badges::Storage::ActiveRecord::Authorization.find_by_authorized_id(1)
    authorization.should_not be_nil
    @ar_store.revoke_role('revokes a role on a class', user, Account)

    authorization = Badges::Storage::ActiveRecord::Authorization.find_by_authorized_id(1)
    authorization.should be_nil
  end

  it 'revokes a role on an instance' do
    user = User.new(1)
    account = Account.new(2)
    @ar_store.grant_role('revokes a role on an instance', user, account)
    authorization = Badges::Storage::ActiveRecord::Authorization.find_by_authorized_id(1)
    authorization.should_not be_nil
    @ar_store.revoke_role('revokes a role on an instance', user, account)
    
    authorization = Badges::Storage::ActiveRecord::Authorization.find_by_authorized_id(1)
    authorization.should be_nil
  end
  
  it "returns authorizations for an authorized" do
    user = User.new(1)
    
    @ar_store.find_authorized_roles(user).should == []
    
    @ar_store.grant_role('global', user)
    @ar_store.grant_role('class', user, Account)
    @ar_store.grant_role('instance', user, Account.new(2))
    @ar_store.grant_role('instance', user, Account.new(3))
    @ar_store.find_authorized_roles(user).should == [{:role=>'global'}, {:role=>'class', :on=>{:class=>'Account'}}, {:role=>'instance', :on=>{:class=>'Account', :id=>'2'}}, {:role=>'instance', :on=>{:class=>'Account', :id=>'3'}}]
  end

  it "returns authorizations for an authorizable" do
    account = Account.new(2)
    
    @ar_store.find_authorizable_roles(account).should == []
    
    @ar_store.grant_role('instance', User.new(1), account)
    @ar_store.grant_role('instance', User.new(2), account)
    
    @ar_store.find_authorizable_roles(account).should == [{:role=>'instance', :by=>{:class=>'User', :id=>'1'}}, {:role=>'instance', :by=>{:class=>'User', :id=>'2'}}]
  end
  
end
