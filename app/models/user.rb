class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  enum gender: { man: 0, woman: 1, other: 2 }

  # user用バリデーション
  validates :nickname, presence: true
  validates :height, presence: true
  validates :weight, presence: true
  validates :gender, presence: true
  validates :introduction, presence: true

  # refile用記述
  attachment :profile_image

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

  # いいね機能のアソシエーション
  has_many :likes, dependent: :destroy

  # 通知機能のアソシエーション
  has_many :notifications, class_name: "Notification", foreign_key: "visitor_id", dependent: :destroy
  has_many :reverse_notifications, class_name: "Notification", foreign_key: "visited_id", dependent: :destroy

  def create_notification_follow!(current_user)
    temp = Notification.where(["visitor_id = ? and visited_id = ? and action = ?", current_user.id, id, 'follow'])
    if temp.blank?
      notification = current_user.notifications.new(
        visited_id: id, action: 'follow'
      )
      notification.save if notification.valid?
    end
  end

  # 検索機能のアソシエーション
  has_many :searches, dependent: :destroy

  # 検索機能のメソッド
  def self.lookup(search, word)
    if search == "perfect_match"
      @users =   User.where("nickname LIKE?", "#{word}")
    elsif search == "forward_match"
      @users =   User.where("nickname LIKE?", "#{word}%")
    elsif search == "backward_match"
      @users =   User.where("nickname LIKE?", "%#{word}")
    elsif search == "partial_match"
      @users =   User.where("nickname LIKE?", "%#{word}%")
    end
  end

  
end
