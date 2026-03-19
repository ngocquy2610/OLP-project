class ChangeTypeColumnInExamsToInteger < ActiveRecord::Migration[6.0]
  def up
    # If you have existing data, you may want to map boolean to integer here
    change_column :exams, :type, :integer, using: 'CASE WHEN type = TRUE THEN 1 WHEN type = FALSE THEN 2 ELSE NULL END'
  end

  def down
    change_column :exams, :type, :boolean
  end
end
