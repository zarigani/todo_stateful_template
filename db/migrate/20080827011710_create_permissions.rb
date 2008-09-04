class CreatePermissions < ActiveRecord::Migration
  def self.up
    create_table :permissions do |t|
      t.integer :role_id, :user_id, :null => false

      t.timestamps
    end
    #Then, add default admin user
    #Be sure change the password later or in this migration file
    user = User.new
    user.login = "admin"
    user.email = "#{USERNAME}@gmail.com"
    user.password = "admin"
    user.password_confirmation = "admin"
    user.register!
    user.activate!
    administrator_role = Role.find_or_create_by_name('administrator')
    user.roles << administrator_role
  end

  def self.down
    drop_table :permissions
    Role.find_by_rolename('administrator').destroy   
    User.find_by_login('admin').destroy   
  end
end