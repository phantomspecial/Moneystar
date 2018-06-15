class CreateCategories < ActiveRecord::Migration[5.1]
  def change
    create_table :categories do |t|
      t.references :top_category, null: false
      t.references :sub_category, null: false
      t.references :cf_category, null: false
      t.integer :uuid, null: false
      t.string :name, null: false
      t.timestamps
    end
  end
end
