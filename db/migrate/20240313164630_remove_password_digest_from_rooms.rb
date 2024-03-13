class RemovePasswordDigestFromRooms < ActiveRecord::Migration[6.0]
  def change
    remove_column :rooms, :password_digest
  end
end
