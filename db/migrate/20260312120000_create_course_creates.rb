class CreateCourseCreates < ActiveRecord::Migration[7.0]
  def change
    create_table :course_creates do |t|
      t.references :course, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true # teacher
      t.timestamps
    end
  end
end
