class CreateTopCategories < ActiveRecord::Migration[5.1]
  def change
    create_table :top_categories do |t|
      t.string :cat_name, null: false
      t.timestamps
    end
  end
end
