class AddIsLastToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :is_last, :boolean, deafault: false
  end
end
