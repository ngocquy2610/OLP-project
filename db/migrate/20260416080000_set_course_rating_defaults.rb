class SetCourseRatingDefaults < ActiveRecord::Migration[8.1]
  def up
    # Backfill existing NULL values to safe defaults
    execute <<-SQL
      UPDATE courses SET rate = 0.0 WHERE rate IS NULL;
      UPDATE courses SET total_rating = 0 WHERE total_rating IS NULL;
    SQL

    # Set DB-level defaults and enforce NOT NULL
    change_column_default :courses, :rate, 0.0
    change_column_null :courses, :rate, false, 0.0

    change_column_default :courses, :total_rating, 0
    change_column_null :courses, :total_rating, false, 0
  end

  def down
    change_column_default :courses, :rate, nil
    change_column_null :courses, :rate, true

    change_column_default :courses, :total_rating, nil
    change_column_null :courses, :total_rating, true
  end
end
