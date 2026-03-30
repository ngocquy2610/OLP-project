class ChangeTypeColumnInExamsToInteger < ActiveRecord::Migration[6.0]
  def up
    # Drop any existing default so Postgres won't attempt to cast it automatically
    execute <<-SQL.squish
      ALTER TABLE exams ALTER COLUMN "type" DROP DEFAULT;
    SQL

    # Map boolean values to integers: TRUE -> 1, FALSE -> 2
    change_column :exams, :type, :integer, using: 'CASE WHEN "type" = TRUE THEN 1 WHEN "type" = FALSE THEN 2 ELSE NULL END'
  end

  def down
    # Map integers back to boolean: 1 -> TRUE, 2 -> FALSE
    change_column :exams, :type, :boolean, using: 'CASE WHEN "type" = 1 THEN TRUE WHEN "type" = 2 THEN FALSE ELSE NULL END'
  end
end
