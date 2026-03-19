class CreateCourses < ActiveRecord::Migration[8.1]
  def change
    create_table :courses do |t|
      t.string :name, null: false
      t.string :image
      t.text :description
      t.decimal :price, null: false

      t.timestamps
    end
  end
end
