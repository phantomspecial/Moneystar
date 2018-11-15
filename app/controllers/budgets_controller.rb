class BudgetsController < MastersController
  def index
    @budgets = Budget.all.order(:uuid)
  end

  def new
    @budget = Budget.new
  end

  def create
    @budget = Budget.new(budget_params)
    return render :new unless @budget.valid?

    @budget.save!
    redirect_to action: :index
  end

  def edit
    @budget = Budget.find(params[:id])
  end

  def update
    @budget = Budget.find(params[:id])
    if @budget.update(budget_params)
      redirect_to action: :index
    else
      redirect_to action: :edit
    end
  end

  def destroy
    Budget.find(params[:id]).destroy
    redirect_to action: :index
  end

  private

  def budget_params
    params.require(:budget).permit(:uuid,
                                   :budget_typ,
                                   :monthly_budget,
                                   :daily_budget,
                                   :weekday_budget,
                                   :holiday_budget,
                                   :even_month_budget,
                                   :odd_month_budget)
  end
end
