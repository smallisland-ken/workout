Rails.application.routes.draw do
  devise_for :users
  resource :favorites, only: [:create, :destroy]
  
  resources :posts, only: [:new, :create, :index, :show, :destroy] do
    resources :comments, only: [:create, :destroy]
    resources :like, only: [:create, :destroy]
  end
  
  resources :notifications, only: [:index]  
  
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
