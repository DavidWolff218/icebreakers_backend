class AddRoomIdToVotes < ActiveRecord::Migration[6.0]
  def change
    add_column :votes, :room_id, :integer
  end
end
