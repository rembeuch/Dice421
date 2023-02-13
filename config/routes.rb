Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  resources :games
  post "leave", to: "games#leave" , as: 'leave'
  post "join", to: "games#join" , as: 'join'
  get "lap", to: "games#lap" , as: 'lap'
  get 'results', to: 'games#results', as: 'results'
  post "reset", to: "games#reset" , as: 'reset'

  post "turn", to: "games#turn" , as: 'turn'

  # Defines the root path route ("/")
  root "games#new"

end
