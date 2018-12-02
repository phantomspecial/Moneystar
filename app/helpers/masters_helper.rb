module MastersHelper
  def category_balance_total_hash
    # 現金/ゆうちょ/UFJ/Suica/SBI/VISAカード/未払水道光熱費の残高算出
    date_maker
    result = {}
    category_data = %w(1101 1104 1105 1108 1601 2106 2107)
    category_data.each do |uuid|
      result[Category.find_by(uuid: uuid).name] = Ledger.category_range_total(uuid, @start_date, @end_date)
    end
    result
  end

  def aggregate_hash
    # 有効現預金(VISA光)/先月末残高/先月末差/現預金合計/総資金合計/負債合計
    date_maker
    result = {}
    result['有効現預金(VISA光)'] = Category.range_cash(@start_date, @end_date)
    result['先月末残高'] = Category.last_month_available_cash
    result['先月末差'] = Category.last_month_diff(@start_date, @end_date)
    result['現預金合計'] = Category.total_cash(@start_date, @end_date)
    result['総資金合計'] = Category.super_total_cash(@start_date, @end_date)
    result['負債合計'] = Category.top_category_range_total(2, @start_date, @end_date)

    result
  end

  def budget_hash(flg)
    result = {}
    Budget.all.pluck(:uuid).each do |uuid|
      name = budget_division_name(uuid) + Category.find_by(uuid: uuid).name
      result[name] = Budget.new.progress_estimate(uuid, flg)
    end

    # 主要変動費合計
    cost_hash = result.select { |i| Category.where(top_category_id: 5).pluck(:name).include?(i) }
    total_hash = {}
    total_hash[:monthly_budget] = cost_hash.values.map { |r| r.values[0] }.inject(:+)
    total_hash[:progress_budget] = cost_hash.values.map { |r| r.values[1] }.inject(:+)
    total_hash[:current_value] = cost_hash.values.map { |r| r.values[2] }.inject(:+)
    total_hash[:estimate_ratio] = '-----'
    total_hash[:devide] = cost_hash.values.map { |r| r.values[4] }.inject(:+)

    result['管理対象費用合計'] = total_hash

    result
  end

  def total_balance_overview(flg)
    result = {}
    start_date, end_date = flg == 'month' ? Budget.new.month_total_days : Budget.new.payday_total_days

    result['期間損益'] = Category.range_pl(start_date, end_date)

    result['期間収支'] = Category.range_cash(start_date, end_date)

    unexpired_days = (end_date.to_date - Time.current.to_date).to_i + 1
    result['1日あたり'] = (result['期間収支'] / unexpired_days).floor

    result
  end

  def progress_remain_days(flg)
    # 経過日数、未経過日数を表示する。
    # 今日は未経過とする。
    start_date, end_date = flg == 'month' ? Budget.new.month_total_days : Budget.new.payday_total_days

    progress_days = (Time.current.to_date - start_date.to_date).to_i
    remain_days = (end_date.to_date - Time.current.to_date).to_i + 1

    "経過日数：#{progress_days}日　　/　　残り日数：#{remain_days}日"
  end

  def budget_division_name(uuid)
    budget = Budget.find_by(uuid: uuid)
    return if budget.nil?
    budget.budget_division == '借方残高増加予算' ? '(借方)' : '(貸方)'
  end

  private

  def date_maker
    @start_date = Time.zone.local(Constants::CURRENT_NENDO, Constants::BEGINNING_OF_NENDO, 1)
    @end_date = Time.current
  end

end
