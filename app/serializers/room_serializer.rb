class RoomSerializer < ActiveModel::Serializer
  attributes :id, :room_name, :host_id, :host_name, :game_started

  has_many :users
  
  def user
    { username: self.object.user.username,
    user_id: self.object.user.id}
  end
end
