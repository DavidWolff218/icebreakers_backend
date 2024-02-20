Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  patch '/users/select', to: 'users#select'
  patch '/users/start', to: 'users#start'
  # patch '/users/voting/foo', to: 'users#voting_select'
  # patch '/users/voting_timer/foo', to: 'users#voting_timer_select'

  get '/users/by_room/:room_id', to: 'users#by_room'
  get '/users/midgame/:room_id', to: 'users#midgame'

  resources :users
  resources :rooms
  resources :questions, only: [:index, :show, :update]

  post '/', to: 'room_auth#create'
  post '/verify_token', to: 'users#verify_token'



  mount ActionCable.server => '/cable'

end
