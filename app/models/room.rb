class Room < ApplicationRecord
  has_many :room_questions, :dependent => :destroy
  has_many :questions, through: :room_questions
  has_many :user_rooms, :dependent => :destroy
  has_many :users, through: :user_rooms
end
