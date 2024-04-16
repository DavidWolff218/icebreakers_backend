class ChangeIsNextDefaultInUsers < ActiveRecord::Migration[6.0]
  def change
    change_column_default :users, :is_next, from: nil, to: false
  end
end
