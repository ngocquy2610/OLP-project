class CreateLikes < ActiveRecord::Migration[7.1] # Số phiên bản có thể khác
  def change
    create_table :likes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :feedback_course, null: false, foreign_key: true

      t.timestamps
    end

    add_index :likes, [ :user_id, :feedback_course_id ], unique: true
  end
end
