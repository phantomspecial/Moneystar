# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180722075308) do

  create_table "categories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "top_category_id", null: false
    t.bigint "sub_category_id", null: false
    t.bigint "cf_category_id", null: false
    t.integer "uuid", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cf_category_id"], name: "index_categories_on_cf_category_id"
    t.index ["sub_category_id"], name: "index_categories_on_sub_category_id"
    t.index ["top_category_id"], name: "index_categories_on_top_category_id"
  end

  create_table "cf_categories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "cat_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "estimates", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "uuid", null: false
    t.integer "m_est", null: false
    t.string "cost_cat", null: false
    t.text "memo1"
    t.text "memo2"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "journal_details", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "journal_id"
    t.bigint "category_id"
    t.integer "division"
    t.integer "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_journal_details_on_category_id"
    t.index ["journal_id"], name: "index_journal_details_on_journal_id"
  end

  create_table "journals", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.text "kogaki", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ledgers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "journal_id", null: false
    t.integer "contra_id", null: false
    t.integer "division"
    t.integer "sfcat_id", null: false
    t.integer "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "monthly_finances", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "month", comment: "月(期首は0とする)"
    t.integer "visa_m_balance", comment: "現金月末残高(VISA)"
    t.integer "bfp_visa_m_balance", comment: "入金前現金残高(VISA)"
    t.integer "m_balance", comment: "現金月末残高"
    t.integer "bfp_flow", comment: "入金前フロー"
    t.integer "free_cf", comment: "FCF"
    t.integer "o_cf", comment: "営業CF"
    t.integer "i_cf", comment: "投資CF"
    t.integer "f_cf", comment: "投資CF"
    t.integer "accum_fcf", comment: "累積FCF"
    t.integer "deposit_cash", comment: "入金額"
    t.integer "payment_cash", comment: "出金額"
    t.integer "super_total_cash", comment: "総合計資金"
    t.integer "super_total_visa_cash", comment: "総合計資金(VISA)"
    t.integer "m_profit", comment: "単純利益"
    t.integer "accum_profit", comment: "累積利益"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "settlement_trials", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "top_category_id", null: false
    t.bigint "sub_category_id", null: false
    t.bigint "cf_category_id", null: false
    t.integer "uuid", null: false
    t.integer "dr_total", null: false
    t.integer "cr_total", null: false
    t.integer "dr_cr_flg", null: false
    t.integer "balance", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cf_category_id"], name: "index_settlement_trials_on_cf_category_id"
    t.index ["sub_category_id"], name: "index_settlement_trials_on_sub_category_id"
    t.index ["top_category_id"], name: "index_settlement_trials_on_top_category_id"
  end

  create_table "sub_categories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "top_category_id", null: false
    t.string "cat_name", null: false
    t.integer "asset_val"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["top_category_id"], name: "index_sub_categories_on_top_category_id"
  end

  create_table "top_categories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "cat_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "username", default: "", null: false
    t.string "tel_number", default: "", null: false
    t.integer "fiscal_year", default: 3, null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
