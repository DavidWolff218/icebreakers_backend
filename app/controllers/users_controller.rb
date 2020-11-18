class UsersController < ApplicationController 


  def index
    all_users = User.all
    room = Room.find(user_params[:room])
    UsersChannel.broadcast_to room, {allUsers: all_users}
  end

  def test
    users = User.all 
    room = Room.find(user_params[:room])
  end

  def create
    user = User.new(user_params)
  end

  def show 
    user = User.find(user_params[:id])
  end

  def voting_select
    vote = Question.find(user_params[:vote_id])
    collection = Vote.find_by(room_id: user_params[:room])
    room = Room.find(user_params[:room])
    current_player = room.users.find_by(username: user_params[:currentPlayer])
    all_users = room.users.all
    if collection.votes_A.length === 0 && collection.votes_B.length === 0
      collection.votes_A << vote.id
      collection.save()
    elsif collection.votes_A[0] === vote.id
      collection.votes_A << vote.id
      collection.save()
    else 
      collection.votes_B << vote.id
      collection.save()
    end
    
    if collection.votes_A.count + collection.votes_B.count === all_users.count
      if collection.votes_A.count > collection.votes_B.count
        current_question = Question.find(collection.votes_A[0])
      elsif collection.votes_A.count < collection.votes_B.count
        current_question = Question.find(collection.votes_B[0])
      end
      p "question", current_question
      p "&&&&&&&&&&&&&", collection
      collection.update(votes_A: [], votes_B: [])
      p "***********", collection
      UsersChannel.broadcast_to room, {  
      currentPlayer: current_player, 
      currentQuestion: current_question,
      votingQuestionA: "",
      votingQuestionB: "", 
      reshufflingUsers: false, 
      reshufflingQuestions: false, 
      allUsers: all_users 
      }
    end
  end

  def select
    reshuffling_users = false
    reshuffling_questions = false
    room = Room.find(user_params[:room])
    all_users = room.users.all
    
    update_user = room.users.find_by(username: user_params[:currentPlayer])
    update_user.update(is_active: false)
    update_question = room.room_questions.find_by(question_id: question_params[:id])
    update_question.update(is_active: false)
    user_array = room.users.select { |user_obj| user_obj.is_active === true }
    
    if user_array.length === 0  
      room.users.map { |user_obj| user_obj.update(is_active: true) } 
      user_array = room.users
      reshuffling_users = true 
    end

    current_player = user_array.sample(1).first
    question_array = room.room_questions.all.select { |user_obj| user_obj.is_active === true }
  
    if question_array.length === 0
      room.room_questions.map { |question_obj| question_obj.update(is_active: true) }
      question_array = room.room_questions
      reshuffling_questions = true
    end

    rand_num = rand(10)
    # if rand_num.even? || rand_num.odd? && question_array.length > 1
    if rand_num && question_array.length > 1
      voting_questions = question_array.sample(2)
      voting_question_A = Question.find(voting_questions.first.question_id)
      voting_question_B = Question.find(voting_questions.second.question_id)
    else
      question_id = question_array.sample(1).first.question_id
      current_question = Question.find(question_id)
    end
   
    UsersChannel.broadcast_to room, { 
      currentPlayer: current_player, 
      currentQuestion: current_question,
      votingQuestionA: voting_question_A,
      votingQuestionB: voting_question_B, 
      reshufflingUsers: reshuffling_users, 
      reshufflingQuestions: reshuffling_questions, 
      allUsers: all_users 
    }
   
  end

  def start
    room = Room.find(user_params[:room])
    all_users = room.users.all
    room.update(game_started: true)
    user_array = room.users.select { |room_obj| room_obj.is_active === true }
    current_player = user_array.sample(1).first
    question_array = room.room_questions.select { |room_obj| room_obj.is_active === true }
    question_id = question_array.sample(1).first.question_id
    current_question = Question.all.find(question_id)
    UsersChannel.broadcast_to room, { currentPlayer: current_player, currentQuestion: current_question, allUsers: all_users, room: room }
  end

  def destroy
    user = User.find(user_params[:id])
    render json: user
    user.destroy
  end

  private

  def user_params
    params.require(:user).permit(:username, :id, :room, :currentPlayer, :currentQuestion, :reshufflingUsers, :vote_id)
  end

  def question_params
    params.require(:question).permit(:id)
  end

end
