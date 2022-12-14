Rails.application.routes.draw do
  # Devise
  devise_for :users, :controllers => {:registrations => "registrations", omniauth_callbacks: "callbacks"}
    # devise_scope :user do
    #   get 'login', to: 'devise/sessions#new'
    # end
    # devise_scope :user do
    #   get 'signup', to: 'devise/registrations#new'
    # end

  # Root route
  root to: "pages#home"

  # All other routes
  get "/profile", to: "users#profile", as: :profile
  resources :users, only: [:index, :show, :edit, :update], path: "all_programmers" do
  end
  patch '/chat_pins/:id', to: 'chat_requests#pin_user', as: :pin_user
  post '/chat_requests', to: 'chat_requests#create', as: :new_chat_request
  resources :chat_requests, only: [:index, :edit, :update]
  resources :chat_rooms, only: [:index, :show] do
    resources :messages, only: :create
  end

  resources :events, only: [:index, :show, :new, :create]
end
