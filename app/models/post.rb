class Post < ApplicationRecord

    attachment :image

    #userのアソシエーション 
    belongs_to :user
      
    # タグ付けのアソシエーション
    has_many :tag_relationships, dependent: :destroy
    has_many :tags, through: :tag_relationships
    
    # タグ付けの新規投稿用メソッド
    def save_tags(tags)
        tags.each do |new_tags|
        tags = Tag.find_or_create_by(name: new_tags)
        # tags = self.tags.find_or_create_by(name: new_tags)
        self.tags << tags
        end
    end
    
    # タグ付けの更新用メソッド
    def update_tags(tags)
        current_tags =self.tags.pluck(:name) unless self.tags.nil?
        old_tags = current_tags - tags
        new_tags = tags - current_tags
        
        old_tags.each do |old_tags|
            self.tags.delete self.tags.find_by(name: old_tags)
        end

        new_tags.each do |new_tags|
        new_tags = self.tags.find_or_create_by(name: new_tags)
        self.tags << new_tags
        end
    end

    
    
    
end