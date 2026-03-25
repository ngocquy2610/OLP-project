class CreatePracticeAttempts < ActiveRecord::Migration[8.1]
  def change
    create_table :practice_attempts do |t|
      t.references :user, null: false, foreign_key: true
      t.references :lesson, null: false, foreign_key: true
      t.float :score
      t.boolean :completed

      t.timestamps
    end
  end
end
