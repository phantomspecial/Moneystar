class CreateMonthlyFinances < ActiveRecord::Migration[5.1]
  def change
    create_table :monthly_finances do |t|
      t.integer :month                  # 月(期首は0とする)
      t.integer :visa_m_balance         # 現金月末残高(VISA)
      t.integer :bfp_visa_m_balance     # 入金前現金残高(VISA)
      t.integer :m_balance              # 現金月末残高
      t.integer :bfp_flow               # 入金前フロー
      t.integer :free_cf                # FCF
      t.integer :o_cf                   # 営業CF
      t.integer :i_cf                   # 投資CF
      t.integer :f_cf                   # 投資CF
      t.integer :accum_cf               # 累積FCF
      t.integer :deposit_cash           # 入金額
      t.integer :payment_cash           # 出金額
      t.integer :super_total_cash       # 総合計資金
      t.integer :super_total_visa_cash  # 総合計資金(VISA)
      t.integer :m_profit               # 単純利益
      t.integer :accum_profit           # 累積利益
      t.timestamps
    end
  end
end
