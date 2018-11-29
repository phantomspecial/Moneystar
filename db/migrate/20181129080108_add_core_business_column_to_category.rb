class AddCoreBusinessColumnToCategory < ActiveRecord::Migration[5.1]
  def up
    add_column :categories, :core_business_flg, :boolean, default: false, null: false, after: :name
  end

  def down
    remove_column :categories, :core_business_flg, :boolean
  end
end
