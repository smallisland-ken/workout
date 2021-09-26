class Tag < ApplicationRecord
  # タグ付けのバリデーション・アソシエーション
  has_many :tag_relationships, dependent: :destroy
  # has_many :posts, through: :tag_relationships
end
