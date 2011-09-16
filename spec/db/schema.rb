ActiveRecord::Schema.define(:version => 0) do

  create_table :badges_test_projects, :force => true do |t|
    t.column :name, :string
  end

  create_table :badges_roles, :force => true do |t|
    t.column :name,               :string
    t.column :created_at,         :datetime
    t.column :updated_at,         :datetime
  end
  
  create_table :badges_authorization, :force => true  do |t|
    t.column :authorized_class,   :string
    t.column :authorized_id,      :string
    t.column :role_id,            :integer
    t.column :authorizable_class, :string
    t.column :authorizable_id,    :string
    t.column :created_at,         :datetime
    t.column :updated_at,         :datetime
  end

  create_table :badges_privileges, :force => true do |t|
    t.column :name,               :string
    t.column :created_at,         :datetime
    t.column :updated_at,         :datetime
  end
  
  create_table :badges_role_privileges, :force => true  do |t|
    t.column :role_id,            :integer
    t.column :privilege_id,       :integer
    t.column :created_at,       :datetime
    t.column :updated_at,       :datetime
  end

end