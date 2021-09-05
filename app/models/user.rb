class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
      
  has_many :posts, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :comments, dependent: :destroy
  
  has_many :favorites, class_name: "Favorite", foreign_key: "follower_id", dependent: :destroy
  has_many :followings, through: :relationships, source: :followed
  has_many :reverse_favorites, class_name: "Favorite", foreign_key: "followed_id", dependent: :destroy
  has_many :followers, through: :reverse_favorites, source: :follower
  # フォロー機能のアソシエーション

  # フォロー判定するためのメソッド
  def follow(user_id)
      relationships.create(followed_id: user_id)
  end
  def unfollow(user_id)
      relationships.find_by(followed_id: user_id).destroy
  end
  def following?(user)
      followings.include?(user)
  end
  # フォローを判定しているメソッドは一番下のみ

  is_impressionable
  attachment :profile_image
         
  enum gender:[ :男性, :女性, :その他]
  
end
