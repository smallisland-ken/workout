class User < ApplicationRecord

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
      
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  
  # フォロー機能のアソシエーション
  has_many :favorites, class_name: "Favorite", foreign_key: "follower_id", dependent: :destroy
  has_many :followings, through: :favorites, source: :follow
  has_many :reverse_favorites, class_name: "Favorite", foreign_key: "follow_id", dependent: :destroy
  has_many :followers, through: :reverse_favorites, source: :follower

  # フォロー・アンフォローするためのメソッド
  # favorites.createのfavoritesはアソシエーションの名前
  # createメソッドの使い方で検索
  def follow(user_id)
      favorites.create(follow_id: user_id)
  end
  def unfollow(user_id)
      favorites.find_by(follow_id: user_id).destroy
  end
  
  # 引数そのものを検索する
  # フォローを判定しているメソッド
  def following?(user)
      followings.include?(user)
  end
 
  #いいね機能のメソッド
  has_many :likes, dependent: :destroy
 
  is_impressionable
  attachment :profile_image
         
  enum gender:[ :男性, :女性, :その他]
  
end
