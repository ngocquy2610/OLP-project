class CreateFeedbackCourses < ActiveRecord::Migration[8.1]
  def change
    create_table :feedback_courses do |t|
      t.references :user, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      t.text :feedback
      t.integer :likes_count
      t.integer :rate

      t.timestamps
    end
  end
end
