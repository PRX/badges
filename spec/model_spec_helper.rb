require 'active_record'
require 'sqlite3'

module Badges
  class TestProject < ActiveRecord::Base
    include Badges::Authorizable
    include Badges::ModelAuthorization

    set_table_name "badges_test_projects"

    authorizable
  
    attr_accessor :peer, :owner
    
    # privilege_required 'can create a new project'=>:create, :on=>:peer, :user=>:owner
    # privilege_required 'can update projects'=>:update
    
  end
end


ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database  => (File.dirname(__FILE__) + "/db/test.db")
)

require (File.dirname(__FILE__) + "/db/schema.rb")
ActiveRecord::Base.connection.execute('delete from badges_test_projects')
