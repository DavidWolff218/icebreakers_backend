class AddIsNextToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :is_next, :boolean, default: false
  end
end
