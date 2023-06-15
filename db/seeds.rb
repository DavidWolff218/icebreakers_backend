# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Question.destroy_all
RoomQuestion.destroy_all
Room.destroy_all
User.destroy_all
UserRoom.destroy_all
Vote.destroy_all


Question.create(content:"What was your first job?")
# Question.create(content:"What is the story of your first kiss?")
Question.create(content:"What is your most embarrassing grade school memory?")
Question.create(content:"What is your favorite memory of Raza?")
Question.create(content:"Who was your first celebrity crush?")
# Question.create(content:"1")
# Question.create(content:"2")
# Question.create(content:"3")
# Question.create(content:"4")
# Question.create(content:"5")
# Question.create(content:"6")
# Question.create(content:"7")


# RoomQuestion.create(room_id: Room.find_by(name: "Party").id, question_id: )

# Room.create(room_name:"Party", password:"xxx")
# User.create(username:"David")

# UserRoom.create(user_id: User.find_by(username: "David").id, room_id: Room.find_by(room_name: "Party").id)

