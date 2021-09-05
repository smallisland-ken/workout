class CreateTagRelationships < ActiveRecord::Migration[5.2]
  def change
    create_table :tag_relationships do |t|
      t.references :post, foreign_key: true
      t.references :tag, foreign_key: true
      t.timestamps
      
      # referencesにすることでindexが自動付与
      # 外部キーには主キー+_idが必要だが、referecesの場合は不要
      # foreign_key:trueで外部キー制約が設定される

    end
  end
end
