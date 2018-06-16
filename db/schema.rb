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

ActiveRecord::Schema.define(version: 20180615144145) do

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
    t.bigint "journal_id"
    t.integer "contra_id", null: false
    t.integer "division"
    t.integer "sfcat_id", null: false
    t.integer "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["journal_id"], name: "index_ledgers_on_journal_id"
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

end
