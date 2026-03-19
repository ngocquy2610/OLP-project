class CreateLessons < ActiveRecord::Migration[8.1]
  def change
    create_table :lessons do |t|
      t.string :name, null: false
      t.string :video, null: false
      t.text :description
      t.references :topic, null: false, foreign_key: true

      t.timestamps
    end
  end
end
