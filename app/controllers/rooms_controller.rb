require "jwt"

class RoomsController < ApplicationController 

  def room_code
    def generate_code()
      charset = Array('A'..'Z')
      Array.new(4) { charset.sample }.join
    end
    room = generate_code()
    while Room.exists?(room_name: room)
      room = generate_code()
    end
    render json: {room_name: room}
  end
  
  def create

    existing_room = Room.find_by(room_name: room_params[:room_name])

    if existing_room
      render json: {error: "That room name already exists, please choose another"}, status: :conflict
      return
    end

    user = User.create({"username" => room_params[:username], :is_active => true})
    room = Room.create({"room_name" => room_params[:room_name], "password" => room_params[:password], "host_id" => user.id, "host_name" => user.username, :game_started => false})
    join = UserRoom.create({"user_id" => user.id, "room_id" => room.id})
    question = Question.all.map {|question_obj| RoomQuestion.create({room_id: room.id, question_id: question_obj.id, is_active: true, is_selected: false})}
    # Vote.create({room_id: room.id})
    
    if room
      payload = {room_id: room.id, user_id: user.id}
      token = JWT.encode(payload, "hmac_secret", 'HS256')
      render json: { room: room, jwt: token, user: user }, status: :created
    else
      render json: { errors: user.errors.messages }, status: :not_acceptable
    end
  end

  def destroy
    room = Room.find(room_params[:id])
    room.users.destroy
    room.user_rooms.destroy
    room.room_questions.destroy
    room.destroy
    UsersChannel.broadcast_to room, {
      endGame: true
    }
  end

  private

  def room_params
    params
      .require(:room)
      .permit(:room_name, :password, :username, :is_active, :id)
  end

end