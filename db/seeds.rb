
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).


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
Question.create(content:"111111111111111111")
Question.create(content:"222222222222222222")
Question.create(content:"333333333333333333")
Question.create(content:"444444444444444444")
Question.create(content:"555555555555555555")
Question.create(content:"666666666666666666")
Question.create(content:"777777777777777777")


# RoomQuestion.create(room_id: Room.find_by(name: "Party").id, question_id: )

# Room.create(room_name:"Party")
# User.create(username:"David")

# UserRoom.create(user_id: User.find_by(username: "David").id, room_id: Room.find_by(room_name: "Party").id)

