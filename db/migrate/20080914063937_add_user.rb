class AddUser < ActiveRecord::Migration
  def self.up
    login_names = ['zarigani', 'yamada']
    login_names.each_with_index do |n, index|
      user = User.new
      user.login = n
      user.email = "#{USERNAME}+#{index+1}@gmail.com"
      user.password = n
      user.password_confirmation = n
      user.register!
      user.activate!
      # administrator_role = Role.find_or_create_by_name('administrator')
      # user.roles << administrator_role
    end
  end

  def self.down
  end
end
