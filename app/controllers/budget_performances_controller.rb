class BudgetPerformancesController < MastersController
  def index
    @pl = BudgetPerformance.profit_and_loss
    @ie = BudgetPerformance.income_and_expenditure
  end
end
