class RoomAuthController < ApplicationController 

  def new
    user = User.new
  end
  
  def create
    room = Room.find_by(room_name: room_params[:room_name])
    if room && room.authenticate(room_params[:password])
      if room.users.exists?(username: room_params[:username])
        render json: {error: "That Player Name is already being used, please pick a new one"}, status: :conflict
        return
      end
      user = User.create({"username" => room_params[:username], :is_active => true})
      join = UserRoom.create({"user_id" => user.id, "room_id" => room.id})
      payload = {room_id: room.id, user_id: user.id}
      token = JWT.encode(payload, "hmac_secret", 'HS256')
      render json: { room: RoomSerializer.new(room), jwt: token, user: user }, status: :accepted
      # code below removed as json handles all needed, keeping for refernce incase later issues
      # all_users = room.users.all
      # UsersChannel.broadcast_to room, {allUsers: all_users, room: room}
    else
      render json: { error: 'Invalid Room Name or Password' }, status: :unauthorized
    end

    
  end


  private

  def room_params
    params.require(:room).permit(:room_name, :password, :username)
  end


end

