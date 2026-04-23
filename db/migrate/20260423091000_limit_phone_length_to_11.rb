class LimitPhoneLengthTo11 < ActiveRecord::Migration[8.1]
  def up
    remove_check_constraint :users, name: "users_phone_format_check"

    add_check_constraint :users,
      "phone IS NOT NULL AND btrim(phone) <> '' AND char_length(phone) <= 11 AND phone ~ '^\\+?[0-9\\s\\-\\(\\)]{10,11}$'",
      name: "users_phone_format_check",
      validate: false
  end

  def down
    remove_check_constraint :users, name: "users_phone_format_check"

    add_check_constraint :users,
      "phone IS NOT NULL AND btrim(phone) <> '' AND phone ~ '^\\+?[0-9\\s\\-\\(\\)]{10,}$'",
      name: "users_phone_format_check",
      validate: false
  end
end
