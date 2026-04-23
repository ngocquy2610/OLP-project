class AddPhoneFormatCheckToUsers < ActiveRecord::Migration[8.1]
  def up
    add_check_constraint :users,
      "phone IS NOT NULL AND btrim(phone) <> '' AND phone ~ '^\\+?[0-9\\s\\-\\(\\)]{10,}$'",
      name: "users_phone_format_check",
      validate: false
  end

  def down
    remove_check_constraint :users, name: "users_phone_format_check"
  end
end
