class AddUserIdToCourses < ActiveRecord::Migration[8.1]
  def change
    add_reference :courses, :user, foreign_key: true, null: true
  end
end
