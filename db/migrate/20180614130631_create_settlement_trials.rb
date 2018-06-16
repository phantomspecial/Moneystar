class CreateSettlementTrials < ActiveRecord::Migration[5.1]
  def change
    create_table :settlement_trials do |t|
      t.references :top_category, null: false
      t.references :sub_category, null: false
      t.references :cf_category, null: false
      t.integer :uuid, null: false
      t.integer :dr_total, null: false
      t.integer :cr_total, null: false
      t.integer :dr_cr_flg, null: false
      t.integer :balance, null: false
      t.timestamps
    end
  end
end
