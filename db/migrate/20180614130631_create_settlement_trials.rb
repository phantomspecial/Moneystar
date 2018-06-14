class CreateSettlementTrials < ActiveRecord::Migration[5.1]
  def change
    create_table :settlement_trials do |t|
      t.integer :uuid
      t.integer :dr_total
      t.integer :cr_total
      t.integer :dr_cr_flg
      t.integer :balance
      t.timestamps
    end
  end
end
