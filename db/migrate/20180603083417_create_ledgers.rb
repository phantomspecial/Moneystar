class CreateLedgers < ActiveRecord::Migration[5.1]
  def change
    create_table :ledgers do |t|
      t.integer :journal_id, null: false
      t.integer :contra_id, null: false
      t.integer :division
      t.integer :sfcat_id, null: false
      t.integer :amount
      t.timestamps
    end
  end
end
