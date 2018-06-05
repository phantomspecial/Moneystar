class CreateJournalDetails < ActiveRecord::Migration[5.1]
  def change
    create_table :journal_details do |t|
      t.references :journal
      t.references :category
      t.integer :division
      t.integer :amount
      t.timestamps
    end
  end
end
