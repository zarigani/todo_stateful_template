class CreateTodos < ActiveRecord::Migration
  def self.up
    create_table :todos do |t|
      t.string :body
      t.date :due
      t.boolean :done
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :todos
  end
end
