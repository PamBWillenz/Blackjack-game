Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "games#new"

  resources :games, only: [:new, :create, :show] do
    member do
      post :deal
      post :hit
      post :stand
      post :new_round
    end
  end
    resources :players, only: [] do
      post :bet, on: :member
      post :reset_balance, on: :member
    end
end
