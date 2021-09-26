class Favorite < ApplicationRecord
  # userへのアソシエーション
  # class_nameがuserモデルとリンクしている(class_nameは大文字でなければNG）
  belongs_to :follow, class_name: "User"
  belongs_to :follower, class_name: "User"
end
