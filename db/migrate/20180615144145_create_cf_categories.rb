class CreateCfCategories < ActiveRecord::Migration[5.1]
  def change
    create_table :cf_categories do |t|
      t.string :cat_name, null: false
      t.timestamps
    end
  end
end
