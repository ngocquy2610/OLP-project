class CreateExamAttempts < ActiveRecord::Migration[8.1]
  def change
    create_table :exam_attempts do |t|
      t.references :user, null: false, foreign_key: true
      t.references :topic, null: false, foreign_key: true
      t.integer :score

      t.timestamps
    end
  end
end
