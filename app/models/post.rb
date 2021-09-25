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
    
    #userのアソシエーション 
    belongs_to :user
    
    #投稿のコメントへのアソシエーション
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
        
        if self.tags.empty?
            # 既存のタグがなかったら追加だけ行う
            latest_tags.each do |latest_tag|
                self.tags.find_or_create_by(name: latest_tag)
            end
        elsif latest_tags.empty?
            # 更新対象のタグがなかったら既存のタグをすべて削除
            self.tags.each do |tag|
                self.tags.delete(tag)
            end
        else
            # 既存のタグも更新対象のタグもある場合は差分更新
            current_tags =self.tags.pluck(:name)
            old_tags = current_tags - latest_tags
            new_tags = latest_tags - current_tags

            old_tags.each do |old_tag|
                tag = self.tags.find_by(name: old_tag)
                self.tags.delete(tag) if tag.present?
            end
        
            new_tags.each do |new_tag|
                self.tags.find_or_create_by(name: new_tag)
                # self.tags << new_tags
            end    
        end    
    end
    
    # 通知機能のアソシエーション
    has_many :notifications, dependent: :destroy
    
    def create_notification_by(current_user)
        notification = current_user.notifications.new(
        post_id: id, visited_id: user_id, action: "like"
        )
        notification.save if notification.valid?
    end
    
    def create_notification_comment!(current_user, comment_id)
        temp_ids = Comment.select(:user_id).where(post_id: self.id).where.not(user_id: current_user.id).distinct
        temp_ids.each do |temp_id|
            save_notification_comment!(current_user, comment_id, temp_id['user_id'])
        end
    
        save_notification_comment!(current_user, comment_id, self.user_id)# if temp_ids.blank?
    end
    
    def save_notification_comment!(current_user, comment_id, visited_id)
        notification = current_user.notifications.new(
            post_id: id, comment_id: comment_id, visited_id: visited_id, action: 'comment'
            )
        if notification.visitor_id == notification.visited_id
           notification.checked = true
        end
        notification.save if notification.valid?
    end
end
