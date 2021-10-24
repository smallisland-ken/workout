class Post < ApplicationRecord
  # 複数写真投稿用のアソシエーション
  has_many :post_images, dependent: :destroy
  accepts_attachments_for :post_images, attachment: :image

  # Post用バリデーション
  validates :place, presence: true
  validates :content, presence: true
  validates :title, presence: true
  validates :rate, presence: true

  # 閲覧数用記述
  is_impressionable
  
  # simplecalendar用の記述
  # start_timeがないとエラーになる
  def start_time
    self.date_on
  end

  # userのアソシエーション
  belongs_to :user

  # 投稿のコメントへのアソシエーション
  has_many :comments, dependent: :destroy

  # いいねのアソシエーション
  has_many :likes, dependent: :destroy

  # いいね判定メソッド
  def liked_by?(user)
    likes.where(user_id: user.id).exists?
  end

  # タグ付けのアソシエーション
  has_many :tag_relationships, dependent: :destroy
  has_many :tags, through: :tag_relationships

  # タグ付けの新規投稿用メソッド
  def save_tags(tags)
    tags.each do |new_tags|
      self.tags.find_or_create_by(name: new_tags)
    end
  end

  # タグ付けの更新用メソッド
  def update_tags(latest_tags)
    if tags.empty?
      # 既存のタグがなかったら追加だけ行う
      latest_tags.each do |latest_tag|
        tags.find_or_create_by(name: latest_tag)
      end
    elsif latest_tags.empty?
      # 更新対象のタグがなかったら既存のタグをすべて削除
      tags.each do |tag|
        tags.delete(tag)
      end
    else
      # 既存のタグも更新対象のタグもある場合は差分更新
      current_tags = tags.pluck(:name)
      old_tags = current_tags - latest_tags
      new_tags = latest_tags - current_tags

      old_tags.each do |old_tag|
        tag = tags.find_by(name: old_tag)
        tags.delete(tag) if tag.present?
      end

      new_tags.each do |new_tag|
        tags.find_or_create_by(name: new_tag)
        # self.tags << new_tags
      end
    end
  end

  # 通知機能のアソシエーション
  has_many :notifications, dependent: :destroy

# 　current_userを書くことでログインしているユーザーの情報のみを引っ張れる　
  def create_notification_like(current_user)
    # 下はイイネした記事のパラメーターからnotificationテーブルに必要な
    # 情報のみを引っ張ってきている
    notification = current_user.notifications.new(post_id: id, visited_id: user_id, action: "like")
    notification.save if notification.valid?
  end

    # 自分以外の投稿者すべてに通知をする
    # つまり投稿1にAさん、Bさんの投稿があり、Cさんが新たにコメントするとAさんとBさんに通知が来る
    # comment_idにはcomment
  def create_notification_comment!(current_user, comment_id)
    # selectはuser_idのみを検索可能
    # whereはpost_idのidを引っ張ってくる
    # where.notは自分以外の情報を引っ張ってくる
    # distinct一意になる。
    temp_ids = Comment.select(:user_id).where(post_id: id).where.not(user_id: current_user.id).distinct
    temp_ids.each do |temp_id|
      save_notification_comment!(current_user, comment_id, temp_id['user_id'])
    end
    # save_notification_comment!は保存するためのメソッドで下のメソッドを使用
    save_notification_comment!(current_user, comment_id, user_id)
  end

  def save_notification_comment!(current_user, comment_id, visited_id)
    notification = current_user.notifications.new(post_id: id, comment_id: comment_id, visited_id: visited_id, action: 'comment')
    # 自分自身の投稿に自分がコメントをしたら通知はいらないのでtrueにする。
    if notification.visitor_id == notification.visited_id
      notification.checked = true
    end
    notification.save if notification.valid?
  end
end
