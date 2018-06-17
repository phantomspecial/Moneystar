class SettlementsController < MastersController
  before_action :set_data

  def trial
    if params[:ex_param] == 'execution'
      SettlementTrial.new.execute_trial_table
    end
    @results = SettlementTrial.all
  end

  def profit
    @results = SettlementTrial.new.profit_st_maker
  end

  def balance
    @results = SettlementTrial.new.balance_st_maker
  end

  def cashflow
    @results = SettlementTrial.new.cashflow_st_maker
  end

  private

  def set_data
    @ledgers = Ledger.all
    @categories = Category.all
  end
end
