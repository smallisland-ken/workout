class CreatePosts < ActiveRecord::Migration[5.2]
  def change
    create_table :posts do |t|
      t.integer :user_id, null: false
      t.date :date_on, null: false
      t.time :time_at, null: false
      t.string :place, null: false
      t.text :content, null: false

      t.timestamps
    end
  end
end
