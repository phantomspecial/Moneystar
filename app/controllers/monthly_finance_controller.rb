class MonthlyFinanceController < MastersController
  def index
    @monthly_finance = MonthlyFinance.all
    @month_array = []
    12.times do |m|
      @month_array << Time.zone.local(Time.current.year, current_user.fiscal_year, 1).since((m + 1).month).month
    end

    # 増加達成率（入金額/出金額）
    deposit_cash_arr = @monthly_finance.pluck(:deposit_cash).compact
    payment_cash_arr = @monthly_finance.pluck(:payment_cash).compact
    if deposit_cash_arr.length == payment_cash_arr.length
      percent = []
      deposit_cash_arr.zip(payment_cash_arr) do |dep, pay|
        percent << ((dep / pay.to_f) * 100).round(2)
      end
    end

    ### gon用データ ###
    gon.graph_label = ['期首',  @month_array.map { |m| m.to_s + '月' }].flatten

    # 各月CFグラフ
    gon.cf_graph_free_cf = @monthly_finance.pluck(:free_cf)
    gon.cf_graph_accum_cf = @monthly_finance.pluck(:accum_cf)
    gon.cf_graph_o_cf = @monthly_finance.pluck(:o_cf)
    gon.cf_graph_i_cf = @monthly_finance.pluck(:i_cf)
    gon.cf_graph_f_cf = @monthly_finance.pluck(:f_cf)

    # 各月残高グラフ
    gon.bl_graph_visa_m_balance = @monthly_finance.pluck(:visa_m_balance)
    gon.bl_graph_bfp_visa_m_balance = @monthly_finance.pluck(:bfp_visa_m_balance)
    gon.bl_graph_m_balance = @monthly_finance.pluck(:m_balance)

    # 総合計資金
    gon.super_total_cash = @monthly_finance.pluck(:super_total_cash)
    gon.super_total_visa_cash = @monthly_finance.pluck(:super_total_visa_cash)

    # 各月増加達成率
    gon.achievement_rate = percent
    gon.standard_line = Array.new(13, 100)

    # 利益
    gon.m_profit = @monthly_finance.pluck(:m_profit)
    gon.accum_profit = @monthly_finance.pluck(:accum_profit)
  end
end
