class UsersController < ApplicationController 

  def by_room
    room_id = params[:room_id]
    room = Room.find(room_id)
    users = room.users.all
    render json: {allUsers: users}
  end

  def create
    user = User.new(user_params)
  end

  def select

    reshuffling_questions = false
    room = Room.find(user_params[:room])
    update_previous_player = room.users.find(user_params[:currentPlayerID])
    if update_previous_player.is_last === true
      update_previous_player.update( is_selected: false)
    else 
      update_previous_player.update(is_active: false, is_selected: false)
    end  
    update_question = room.room_questions.find_by(question_id: question_params[:id])
    update_question.update(is_active: false, is_selected: false)
    user_array = room.users.select { |user_obj| user_obj.is_active === true && user_obj.is_next === false }
    
    if user_array.length === 0  
      # user_array = room.users
      current_player = room.users.find(user_params[:nextPlayer])
      current_player.update(is_next: false, is_selected: true, is_last: true)
      users_reload = room.reload.users 
      users_reload.map { |user_obj| user_obj.update(is_active: true) } 
      filtered_users = users_reload.reject { |user| user.is_selected }
      next_player = filtered_users.sample(1).first
      next_player.update(is_next: true)   
    else
      current_player = room.users.find(user_params[:nextPlayer])
      current_player.update(is_next: false, is_selected: true)
      next_player = user_array.sample(1).first
      next_player.update(is_next: true)
    end
    
    question_array = room.room_questions.all.select { |question_obj| question_obj.is_active === true }

    if question_array.length === 0
      room.room_questions.map { |question_obj| question_obj.update(is_active: true) }
      question_array = room.room_questions
      reshuffling_questions = true
    end

    # rand_num = rand(10)
    # # if rand_num.even? && question_array.length > 1
    # if rand_num && question_array.length > 1 
    #   voting_questions = question_array.sample(2)
    #   voting_question_A = Question.find(voting_questions.first.question_id)
    #   voting_question_B = Question.find(voting_questions.second.question_id)
    # else
    #   question_id = question_array.sample(1).first.question_id
    #   current_question = Question.find(question_id)
    # end

    question = question_array.sample(1).first
    question.update(is_selected: true)
    current_question = Question.find(question.question_id)
    send_current_player = {username: current_player.username, id: current_player.id}
    send_next_player = {username: next_player.username, id: next_player.id}
  
    UsersChannel.broadcast_to room, { 
      currentPlayer: send_current_player, 
      currentQuestion: current_question,
      nextPlayer: send_next_player,
      # votingQuestionA: "",
      # votingQuestionB: "", 
      # reshufflingUsers: reshuffling_users, 
      reshufflingQuestions: reshuffling_questions, 
      room: room
    }
   
  end

  def start
    room = Room.find(user_params[:room])
    
    user_array = room.users.select { |user_obj| user_obj.is_active === true }
    
    if user_array.length <= 1
      render json: { error: "There needs to be more than one player to start the game." }, status: :unprocessable_entity
      return
    end
    room.update(game_started: true)
    current_player, next_player = user_array.sample(2)
    current_player.update(is_selected: true)
    next_player.update(is_next: true)   
    question_array = room.room_questions.select { |room_obj| room_obj.is_active === true }
    question = question_array.sample(1).first
    question.update(is_selected: true)
    current_question = Question.find(question.question_id)
    send_current_player = {username: current_player.username, id: current_player.id}
    send_next_player = {username: next_player.username, id: next_player.id}
    UsersChannel.broadcast_to room, { currentPlayer: send_current_player, currentQuestion: current_question, room: room, nextPlayer: send_next_player }
  end

  def verify_token
    token = request.headers['Authorization']&.split(' ')&.last
    if token
      begin
        decoded_token = JWT.decode(token, 'hmac_secret', true, algorithm: 'HS256')
        payload = decoded_token.first
        user_id = payload['user_id']
        room_id = payload['room_id']
        room = Room.find(room_id)
        user = User.find(user_id)
        selected_user = room.users.find_by(is_selected: true)
        selected_question = room.room_questions.find_by(is_selected: true)
        # might want to add find_by! for error handling
        render json: ({room: room, user: user})
      rescue JWT::DecodeError => e
        render json: { error: 'Invalid token' }, status: :unauthorized
      end
    else
      render json: { error: 'Token not provided' }, status: :unauthorized
    end
  end

  def midgame
    room = Room.find(params[:room_id])
    all_users = room.users.all
    begin
      current_player = room.users.find_by!(is_selected: true)
      next_player = room.users.find_by!(is_next: true)
      send_current_player = {username: current_player.username, id: current_player.id}
      send_next_player = {username: next_player.username, id: next_player.id}
      active_question = room.room_questions.find_by!(is_selected: true)
      current_question = Question.find(active_question.question_id)
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: "An error occurred while fetching data: #{e.message}" }, status: :not_found
    end
    UsersChannel.broadcast_to room, { allUsers: all_users }
    render json: {allUsers: all_users, currentPlayer: send_current_player, nextPlayer: send_next_player, currentQuestion: current_question, room: room }
    # check to see if sending the whole room object is needed
  end

  def destroy
    user = User.find(user_params[:id])
    user.destroy
    render json: user
  end

  private

  def user_params
    params.require(:user).permit(:username, :id, :room, :currentPlayer, :currentPlayerID, :currentQuestion, :reshufflingUsers, :vote_id, :nextPlayer)
  end

  def question_params
    params.require(:question).permit(:id)
  end

end




  # def voting_select
  #   vote = Question.find(user_params[:vote_id])
  #   collection = Vote.find_by(room_id: user_params[:room])
  #   room = Room.find(user_params[:room])
  #   current_player = room.users.find_by(username: user_params[:currentPlayer])
  #   all_users = room.users.all
  #   if collection.votes_A.length === 0 && collection.votes_B.length === 0
  #     collection.votes_A << vote.id
  #     collection.save()
  #   elsif collection.votes_A[0] === vote.id
  #     collection.votes_A << vote.id
  #     collection.save()
  #   else 
  #     collection.votes_B << vote.id
  #     collection.save()
  #   end
    
  #   if collection.votes_A.count + collection.votes_B.count === all_users.count
  #     if collection.votes_A.count > collection.votes_B.count
  #       current_question = Question.find(collection.votes_A[0])
  #     elsif collection.votes_A.count < collection.votes_B.count
  #       current_question = Question.find(collection.votes_B[0])
  #     elsif collection.votes_A.count === collection.votes_B.count
  #       rand_num = rand(2)
  #       if rand_num.even?
  #         current_question = Question.find(collection.votes_A[0])
  #       else 
  #         current_question = Question.find(collection.votes_B[0])
  #       end
  #     end
  #     collection.update(votes_A: [], votes_B: [])
  #     UsersChannel.broadcast_to room, {  
  #     currentPlayer: current_player, 
  #     currentQuestion: current_question,
  #     votingQuestionA: "",
  #     votingQuestionB: "", 
  #     reshufflingUsers: false, 
  #     reshufflingQuestions: false, 
  #     allUsers: all_users 
  #     }
  #   end
  # end

#   def voting_timer_select
#     collection = Vote.find_by(room_id: user_params[:room])
#     room = Room.find(user_params[:room])
#     current_player = room.users.find_by(username: user_params[:currentPlayer])
#     all_users = room.users.all
#     p "###############", collection
#     if collection.votes_A.count > collection.votes_B.count
#       current_question = Question.find(collection.votes_A[0])
#       # p "^^^^^^^^^^^^^^HERE^^^^^^^^^^^^", current_question
#     elsif collection.votes_A.count < collection.votes_B.count
#       current_question = Question.find(collection.votes_B[0])
#     elsif collection.votes_A.count === collection.votes_B.count
#       rand_num = rand(2)
#       if rand_num.even?
#         current_question = Question.find(collection.votes_A[0])
#       else 
#         current_question = Question.find(collection.votes_B[0])
#       end
#     end
#       collection.update(votes_A: [], votes_B: [])
#       UsersChannel.broadcast_to room, {  
#       currentPlayer: current_player, 
#       currentQuestion: current_question,
#       votingQuestionA: "",
#       votingQuestionB: "", 
#       reshufflingUsers: false, 
#       reshufflingQuestions: false, 
#       allUsers: all_users 
#       }
# end