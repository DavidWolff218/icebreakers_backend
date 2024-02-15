class AddIsSelectedToRoomQuestions < ActiveRecord::Migration[6.0]
  def change
    add_column :room_questions, :is_selected, :boolean
  end
end
