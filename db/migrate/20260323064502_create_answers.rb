class CreateAnswers < ActiveRecord::Migration[8.1]
  def change
    create_table :answers do |t|
      t.references :user, null: false, foreign_key: true
      # `questions` table isn't present in this migrations set; store the id without adding a DB-level foreign key.
      t.bigint :question_id, null: false
      t.string :selected_answer
      t.boolean :correct

      t.timestamps
    end
    add_index :answers, :question_id
  end
end
