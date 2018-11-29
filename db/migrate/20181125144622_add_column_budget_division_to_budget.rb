class AddColumnBudgetDivisionToBudget < ActiveRecord::Migration[5.1]
  def up
    add_column :budgets, :budget_division, :integer, after: :budget_typ
  end

  def down
    remove_column :budgets, :budget_division, :integer
  end
end
