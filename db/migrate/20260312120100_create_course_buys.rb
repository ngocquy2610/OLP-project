class CreateCourseBuys < ActiveRecord::Migration[7.0]
  def change
    create_table :course_buys do |t|
      t.references :course, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true # student
      t.timestamps
    end
  end
end
