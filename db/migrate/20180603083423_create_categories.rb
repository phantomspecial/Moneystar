class CreateCategories < ActiveRecord::Migration[5.1]
  def change
    create_table :categories do |t|
      t.integer :uuid, null: false
      t.string :cat_name, null: false
      t.string :cf_cat, null: false
      t.string :name, null: false
      t.timestamps
    end
  end
end
