class AddIsSelectedToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :is_selected, :boolean
  end
end
