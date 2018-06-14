class SettlementsController < MastersController
  before_action :set_data

  def trial
    if params[:ex_param] == 'execution'
      SettlementTrial.new.execute_trial_table
    end
    @results = SettlementTrial.all
  end

  def profit
  end

  def balance
  end

  def cashflow
  end

  # 貸借合計と損益計算書利益・貸借対照表利益の一致を判定する

  private

  def set_data
    @ledgers = Ledger.all
    @categories = Category.all
  end
end
