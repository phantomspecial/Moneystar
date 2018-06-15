class CreateSubCategories < ActiveRecord::Migration[5.1]
  def change
    create_table :sub_categories do |t|
      t.references :top_category, null: false
      t.string :cat_name, null: false
      t.integer :asset_val
      t.timestamps
    end
  end
end
