Rails.application.routes.draw do
  
  # これをいれることでlocaleをパスに含められる
  # scopeを使用するとurlパターンのみを変更可能
  # locale => /en|ja/ doと書かないとdeviseのパスワード再発行でi18nの影響でエラーになる
  scope '(:locale)', :locale => /en|ja/ do  
    
    # postのindexをルートに設定
    root 'posts#index'
  
    # 自作したアクション名を使用したい場合はresourcesより上に記載しないとresourcesが先に処理されてしまうため注意。
    # resources;usersの下にget 'users/friends' => 'users#friends'を記載するとshowアクションが読み込まれてしまう。
  
    get 'users/friends' => 'users#friends'
  
    devise_for :users
  
    # users用のURL用に設定
    resources :users, only: [:edit, :update] do
      # フォロー機能はuserにネストさせている
      resource :favorites, only: [:create, :destroy]
      get 'followings' => 'favorites#followings', as: 'followings'
      get 'followers' => 'favorites#followers', as: 'followers'
      get 'example', to: 'users#example'
    end
  
    get "search" => "searches#search"
  
    # 投稿機能にネストさせる形でコメントといいね機能を設定
    resources :posts do
      resources :comments, only: [:create, :destroy]
      resource :likes, only: [:create, :destroy]
      # 筋トレ投稿内容を一覧表示のためのURL
      collection do
        get 'diary'
        get 'friends/:id', to: 'posts#friend', as: 'friend'
        get 'calendar'
      end
    end
  
    # 通知機能のルート
    resources :notifications, only: [:index, :destroy]
  end
end
