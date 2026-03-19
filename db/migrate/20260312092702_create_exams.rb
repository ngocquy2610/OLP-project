class CreateExams < ActiveRecord::Migration[8.1]
  def change
    create_table :exams do |t|
      t.text :question, null: false
      t.text :answers, null: false
      t.text :correct_answers, null: false
      t.boolean :type, null: false, default: false
      t.references :topic, null: false, foreign_key: true

      t.timestamps
    end
  end
end
