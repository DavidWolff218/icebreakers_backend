class RoomAuthController < ApplicationController

  def create
    room = Room.find_by(room_name: room_params[:room_name])
    if room
      if room.users.exists?(username: room_params[:username])
        render json: {error: "That Player Name is already being used, please pick a new one"}, status: :conflict
        return
      end
      user = User.create({"username" => room_params[:username], :is_active => true})
      join = UserRoom.create({"user_id" => user.id, "room_id" => room.id})
      payload = {room_id: room.id, user_id: user.id}
      token = JWT.encode(payload, "hmac_secret", 'HS256')
      # moved this broadcast (for waiting room names), to above render json for clarity, can be mvoed below if side effects noticed
      all_users = room.users.all
      # UsersChannel.broadcast_to room, {allUsers: all_users, room: room}
      render json: { room: RoomSerializer.new(room), jwt: token, user: user }, status: :accepted
    else
      render json: { error: 'Invalid Room Name' }, status: :unauthorized
    end
  end

  private

  def room_params
    params.require(:room).permit(:room_name, :username)
  end

end

