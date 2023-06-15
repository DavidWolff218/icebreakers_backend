class CreateVotes < ActiveRecord::Migration[6.0]
  def change
    create_table :votes do |t|
      t.string :votes_A, array: true, default: []
      t.string :votes_B, array: true, default: []

      t.timestamps
    end
  end
end
