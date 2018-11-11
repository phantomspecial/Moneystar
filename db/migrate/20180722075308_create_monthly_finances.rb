class CreateMonthlyFinances < ActiveRecord::Migration[5.1]
  def change
    create_table :monthly_finances do |t|
      t.integer :month,                  comment: '月(期首は0とする)'
      t.integer :visa_m_balance,         comment: '現金月末残高(VISA)'
      t.integer :bfp_visa_m_balance,     comment: '入金前現金残高(VISA)'
      t.integer :m_balance,              comment: '現金月末残高'
      t.integer :bfp_flow,               comment: '入金前フロー'
      t.integer :free_cf,                comment: 'FCF'
      t.integer :o_cf,                   comment: '営業CF'
      t.integer :i_cf,                   comment: '投資CF'
      t.integer :f_cf,                   comment: '投資CF'
      t.integer :accum_cf,               comment: '累積FCF'
      t.integer :deposit_cash,           comment: '入金額'
      t.integer :payment_cash,           comment: '出金額'
      t.integer :super_total_cash,       comment: '総合計資金'
      t.integer :super_total_visa_cash,  comment: '総合計資金(VISA)'
      t.integer :m_profit,               comment: '単純利益'
      t.integer :accum_profit,           comment: '累積利益'
      t.timestamps
    end
  end
end
