class CreateBudgets < ActiveRecord::Migration[5.1]
  def change
    create_table :budgets do |t|
      t.integer             :uuid,                foreign_key: true,            comment: 'UUID'
      t.integer             :budget_typ,                                        comment: '予算タイプ'
      t.integer             :monthly_budget,                                    comment: '定額予算月額'
      t.integer             :daily_budget,                                      comment: '定額予算日額'
      t.integer             :weekday_budget,                                    comment: '平日予算日額'
      t.integer             :holiday_budget,                                    comment: '土日予算日額'
      t.integer             :even_month_budget,                                 comment: '偶数月予算月額'
      t.integer             :odd_month_budget,                                  comment: '奇数月予算月額'
      t.timestamps
    end
  end
end
