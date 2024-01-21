class RoomAuthController < ApplicationController 

  def new
    user = User.new
  end
  
  def create
    room = Room.find_by(room_name: room_params[:room_name])
    if room && room.authenticate(room_params[:password])
      user = User.create({"username" => room_params[:username], :is_active => true})
      join = UserRoom.create({"user_id" => user.id, "room_id" => room.id})
      payload = {room_id: room.id}
      token = JWT.encode(payload, "hmac_secret", 'HS256')
      render json: { room: RoomSerializer.new(room), jwt: token, user: user }, status: :accepted
      # code below does send off what i need when a new user is made, but need to clean up how front proccess this
      # all_users = room.users.all
      # UsersChannel.broadcast_to room, {allUsers: all_users, room: room}
    else
      render json: { error: 'Invalid roomname or password' }, status: :unauthorized
    end

    
  end


  private

  def room_params
    params.require(:room).permit(:room_name, :password, :username)
  end


end

