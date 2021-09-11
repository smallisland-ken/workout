class TagRelationship < ApplicationRecord

    belongs_to :post
    belongs_to :tag
    # タグ付けのバリデーション・アソシエーション
    # validateをいれることで重複を防ぐ
    validates :post_id, presence:true
    validates :tag_id, presence:true
        
end
