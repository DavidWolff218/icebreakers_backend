Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  patch '/users/select/foo', to: 'users#select'
  patch '/users/voting/foo', to: 'users#voting_select'
  patch '/users/start/foo', to: 'users#start'
  patch '/users/voting_timer/foo', to: 'users#voting_timer_select'

  resources :users
  resources :rooms
  resources :questions, only: [:index, :show, :update]

  post '/', to: 'room_auth#create'

  post '/users/test', to: 'users#test'

  mount ActionCable.server => '/cable'

end
