require "jwt"


class RoomsController < ApplicationController 

  def new
    room = Room.new
    user = User.new
  end
  
  def create
    p params
    user = User.create({"username" => room_params[:username], :is_active => true})
    room = Room.create({"room_name" => room_params[:room_name], "password" => room_params[:password], "host_id" => user.id, "host_name" => user.username, :game_started => false})
    join = UserRoom.create({"user_id" => user.id, "room_id" => room.id})
    question = Question.all.map {|questionObj| RoomQuestion.create({room_id: room.id, question_id: questionObj.id, is_active: true})}
    if room
  
      payload = {room_id: room.id}
      token = JWT.encode(payload, "hmac_secret", 'HS256') 
      render json: { room: room, jwt: token, user: user }, status: :created
        
    else
      render json: { errors: user.errors.messages }, status: :not_acceptable
    end

  

  end

  
  def destroy
    room = Room.find(room_params[:id])
    render json: room
    room.users.destroy
    room.user_rooms.destroy
    room.room_questions.destroy
    room.destroy
  end


  private

  def room_params
    params.require(:room).permit(:room_name, :password, :username, :is_active, :id)
  end

  # def user_params
  #   params.require(:user).permit(:username)
  #   # why this no work
  # end




end