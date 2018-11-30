class AddDefaultDivisionColumnToCategory < ActiveRecord::Migration[5.1]
  def up
    add_column :categories, :default_division, :boolean, default: false, null: false, after: :name
  end

  def down
    remove_column :categories, :default_division, :boolean
  end
end
