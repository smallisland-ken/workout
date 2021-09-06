Rails.application.routes.draw do
  root 'posts#index'
  # postのindexをルートに設定
    
  
  get 'users/friends' => 'users#friends'
  # 自作したアクション名を使用したい場合はresourcesより上に記載しないとresourcesが先に処理されてしまうため注意。
  # resources;usersの下にget 'users/friends' => 'users#friends'を記載するとshowアクションが読み込まれてしまう。
  
  devise_for :users
  resources :users do
  # users用のURL用に設定
  resource :favorites, only: [:create, :destroy]
  get 'followings' => 'favorites#followings', as: 'followings'
  get 'followers' => 'favoritess#followers', as: 'followers'
  end  
  # フォロー機能はuserにネストさせている
  
  resources :posts, only: [:index, :new, :create, :show, :destroy, :diary] do
    resources :comments, only: [:create, :destroy]
    resources :like, only: [:create, :destroy]
    collection do
      get 'diary'
    end
    # 筋トレ投稿内容を一覧表示のためのURL
    
  end
  # 投稿機能にネストさせる形でコメントといいね機能を設定
  
  resources :notifications, only: [:index]  
  # 通知機能一覧用のルート
  
end
