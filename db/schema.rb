# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_04_14_062024) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "answers", force: :cascade do |t|
    t.boolean "correct"
    t.datetime "created_at", null: false
    t.bigint "question_id", null: false
    t.string "selected_answer"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["question_id"], name: "index_answers_on_question_id"
    t.index ["user_id"], name: "index_answers_on_user_id"
  end

  create_table "cart_items", force: :cascade do |t|
    t.bigint "cart_id", null: false
    t.bigint "course_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cart_id"], name: "index_cart_items_on_cart_id"
    t.index ["course_id"], name: "index_cart_items_on_course_id"
  end

  create_table "carts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_carts_on_user_id"
  end

  create_table "course_buys", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["course_id"], name: "index_course_buys_on_course_id"
    t.index ["user_id"], name: "index_course_buys_on_user_id"
  end

  create_table "course_creates", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["course_id"], name: "index_course_creates_on_course_id"
    t.index ["user_id"], name: "index_course_creates_on_user_id"
  end

  create_table "courses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "image"
    t.string "name", null: false
    t.decimal "price", null: false
    t.integer "status", default: 0
    t.string "tag"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_courses_on_user_id"
  end

  create_table "enrollments", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["course_id"], name: "index_enrollments_on_course_id"
    t.index ["user_id"], name: "index_enrollments_on_user_id"
  end

  create_table "exam_attempts", force: :cascade do |t|
    t.boolean "completed"
    t.datetime "created_at", null: false
    t.integer "score"
    t.bigint "topic_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["topic_id"], name: "index_exam_attempts_on_topic_id"
    t.index ["user_id"], name: "index_exam_attempts_on_user_id"
  end

  create_table "exams", force: :cascade do |t|
    t.text "answers", null: false
    t.text "correct_answers", null: false
    t.datetime "created_at", null: false
    t.text "question", null: false
    t.bigint "topic_id", null: false
    t.integer "type", null: false
    t.datetime "updated_at", null: false
    t.index ["topic_id"], name: "index_exams_on_topic_id"
  end

  create_table "lessons", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.bigint "topic_id", null: false
    t.datetime "updated_at", null: false
    t.index ["topic_id"], name: "index_lessons_on_topic_id"
  end

  create_table "order_items", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.datetime "created_at", null: false
    t.bigint "order_id", null: false
    t.decimal "price"
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_order_items_on_course_id"
    t.index ["order_id"], name: "index_order_items_on_order_id"
  end

  create_table "orders", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.decimal "discount", precision: 12, scale: 2, default: "0.0", null: false
    t.string "status"
    t.decimal "total"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.bigint "voucher_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
    t.index ["voucher_id"], name: "index_orders_on_voucher_id"
  end

  create_table "practice_attempts", force: :cascade do |t|
    t.boolean "completed"
    t.datetime "created_at", null: false
    t.bigint "lesson_id", null: false
    t.float "score"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["lesson_id"], name: "index_practice_attempts_on_lesson_id"
    t.index ["user_id"], name: "index_practice_attempts_on_user_id"
  end

  create_table "practices", force: :cascade do |t|
    t.text "answers", null: false
    t.text "correct_answers", null: false
    t.datetime "created_at", null: false
    t.bigint "lesson_id", null: false
    t.text "question", null: false
    t.boolean "type", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["lesson_id"], name: "index_practices_on_lesson_id"
  end

  create_table "topics", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_topics_on_course_id"
  end

  create_table "users", force: :cascade do |t|
    t.text "address"
    t.datetime "confirmation_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "fullname"
    t.string "phone"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role", default: 0
    t.string "unconfirmed_email"
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vouchers", force: :cascade do |t|
    t.boolean "active", default: true
    t.decimal "active_price"
    t.string "code"
    t.datetime "created_at", null: false
    t.integer "discount_percent"
    t.datetime "expires_at"
    t.datetime "updated_at", null: false
    t.integer "usage_limit"
    t.integer "used_count", default: 0
    t.index ["code"], name: "index_vouchers_on_code", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "answers", "users"
  add_foreign_key "cart_items", "carts"
  add_foreign_key "cart_items", "courses"
  add_foreign_key "carts", "users"
  add_foreign_key "course_buys", "courses"
  add_foreign_key "course_buys", "users"
  add_foreign_key "course_creates", "courses"
  add_foreign_key "course_creates", "users"
  add_foreign_key "courses", "users"
  add_foreign_key "enrollments", "courses"
  add_foreign_key "enrollments", "users"
  add_foreign_key "exam_attempts", "topics"
  add_foreign_key "exam_attempts", "users"
  add_foreign_key "exams", "topics"
  add_foreign_key "lessons", "topics"
  add_foreign_key "order_items", "courses"
  add_foreign_key "order_items", "orders"
  add_foreign_key "orders", "users"
  add_foreign_key "orders", "vouchers"
  add_foreign_key "practice_attempts", "lessons"
  add_foreign_key "practice_attempts", "users"
  add_foreign_key "practices", "lessons"
  add_foreign_key "topics", "courses"
end
