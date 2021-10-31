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

  #current_userを書くことでログインしているユーザーの情報のみを引っ張れる
  def create_notification_like(current_user)
    # 下はイイネした記事のパラメーターからnotificationテーブルに必要な
    # 情報のみを引っ張ってきている
    # user_idは@postにuser_idが入っているので、それを活用している。
    # visitor_idにはcurrent_user.notificationsでアソシエーションしているので
    # 自動でvisitor_idにcurrent_userの情報が入る
    notification = current_user.notifications.new(post_id: id, visited_id: user_id, action: "like")
    notification.save if notification.valid?
  end

    # 自分以外の投稿者すべてに通知をする
    # つまり投稿1にAさん、Bさんの投稿があり、Cさんが新たにコメントするとAさんとBさんに通知が来る
    # 下記メソッドにはcomments_comtrolerの@postの情報を保持したままメソッドを実行可能
    # つまりcreate_notification_comment!(current_user, comment_id)の引数の情報だけではなく
    # @postに紐づく、user_idと_post_idの情報も@postでコントローラーにて書くことでコードには書いてないけど値として引き渡せる
  def create_notification_comment!(current_user, comment_id)
    # selectはcommentモデルのuser_idを使用しまうと選択しているだけで実際には値がはいっていない
    # つまりselectは選択で、指定をしているのはその後ろのwhere以降でcurrent_user.id以外のuser_idと指定している
    # whereはpost_idのidを引っ張ってくる
    # where.notは自分以外の情報を引っ張ってくる
    # distinct一意になる。
    # それらの一つ一つの情報をeachで回してtemp_idにはcurrent_user.id以外のuser_idが格納されて、eachのtemp_id['user_id']に格納される
    temp_ids = Comment.select(:user_id).where(post_id: id).where.not(user_id: current_user.id).distinct
    temp_ids.each do |temp_id|
    #スコープ内であればスコープ内の引数を使用することが可能
    #しかしeachの中のスコープから外のスコープに引数を引っ張ることができない
    #current_user,comment_idは一つ上から引数を受け取っている
      save_notification_comment!(current_user, comment_id, temp_id['user_id'])
    end
    # save_notification_comment!は保存するためのメソッドで下のメソッドを使用
    # user_idは@postにuser_idがあるので記載ができる
    save_notification_comment!(current_user, comment_id, user_id)
  end

  def save_notification_comment!(current_user, comment_id, visited_id)
    # current_user.notifications.newとアソシエーションになっており
    # userモデルのnotificationsの外部キーがvisitor_idなのでvisited_idにはcurrent_userのidが自動で入るようになる
    # というのも.new以降の引数でvisited_idが3つ目で指定されているので残りのvisitor_idにcurrent_userのidが入る仕組み
    # 質問事項として下記引数の順番はsave_notifiaction_comment!の引数の順番と一致してなくてOKなのか？ 
    notification = current_user.notifications.new(post_id: id, comment_id: comment_id, visited_id: visited_id, action: 'comment')
    # 自分自身の投稿に自分がコメントをしたら通知はいらないのでtrueにする。
    if notification.visitor_id == notification.visited_id
      notification.checked = true
    end
    notification.save if notification.valid?
  end
end
