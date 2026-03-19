class CreateTopics < ActiveRecord::Migration[8.1]
  def change
    create_table :topics do |t|
      t.string :name, null: false
      t.text :description
      t.references :course, null: false, foreign_key: true

      t.timestamps
    end
  end
end
