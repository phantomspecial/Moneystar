class CreateEstimates < ActiveRecord::Migration[5.1]
  def change
    create_table :estimates do |t|
      t.integer :uuid, null: false
      t.integer :m_est, null: false
      t.string :cost_cat, null: false
      t.text :memo1
      t.text :memo2
      t.timestamps
    end
  end
end
