module MastersHelper
  FIXED_COST_UUIDS = [5203, 5205, 5210, 5214, 5302]
  AMORTIZATION_UUIDS = [5208, 5209]

  def category_total(uuid, default_division)
    # その科目の単純合計
    dr_t = @ledgers.where(sfcat_id: uuid).where(division: 1).sum(:amount)
    cr_t = @ledgers.where(sfcat_id: uuid).where(division: 2).sum(:amount)
    default_division == 1 ? dr_t - cr_t : cr_t - dr_t
  end

  def available_cash
    tc = total_cash
    visa = category_total(2106, 2)
    unpay_utils = category_total(2107, 2)
    @available_cash =  tc - visa - unpay_utils
  end

  def last_month_cash
    lm = Time.current.ago(1.month).end_of_month
    cf_visa_util_range = @categories.where(cf_category_id: 1).pluck(:uuid).push([2106, 2107])
    dr_t = 0
    cr_t = 0
    cf_visa_util_range.each do |uuid|
      dr_t += @ledgers.where(sfcat_id: uuid).where(division: 1).where('created_at <= ?', lm).sum(:amount)
      cr_t += @ledgers.where(sfcat_id: uuid).where(division: 2).where('created_at <= ?', lm).sum(:amount)
    end
    @last_month_cash =  dr_t - cr_t
  end

  def last_month_diff
    @last_month_diff = @available_cash - @last_month_cash
  end

  def total_cash
    cf_range = @categories.where(cf_category_id: 1).pluck(:uuid)
    dr_t = 0
    cr_t = 0
    cf_range.each do |uuid|
      dr_t += @ledgers.where(sfcat_id: uuid).where(division: 1).sum(:amount)
      cr_t += @ledgers.where(sfcat_id: uuid).where(division: 2).sum(:amount)
    end
    @total_cash = dr_t - cr_t
  end

  def super_total_cash
    sbi = category_total(1601, 1)
    @super_total_cash =  @total_cash + sbi
  end

  def debt_total
    debt_range = @categories.where(top_category_id: 2).pluck(:uuid)
    dr_t = 0
    cr_t = 0
    debt_range.each do |uuid|
      dr_t += @ledgers.where(sfcat_id: uuid).where(division: 1).sum(:amount)
      cr_t += @ledgers.where(sfcat_id: uuid).where(division: 2).sum(:amount)
    end
    @debt_total = cr_t - dr_t
  end

  def category_range_total(uuid, default_division, start_date, end_date)
    # 与えられたUUIDを持つ科目の、start_dateからend_dateまでの間の残高を求める
    range = @ledgers.where(sfcat_id: uuid).where('created_at >= ? AND created_at <= ?', start_date, end_date)
    dr_t = range.where(division: 1).sum(:amount)
    cr_t = range.where(division: 2).sum(:amount)
    default_division == 1 ? dr_t - cr_t : cr_t - dr_t
  end

  def sub_category_range_total(sub_category_id, default_division, start_date, end_date)
    # 与えられたSubCategoryIDに紐づく科目の、start_dateからend_dateまでの間の残高を求める
    uuids = @categories.where('sub_category_id = ?', sub_category_id).pluck(:uuid)
    total = 0

    uuids.each do |uuid|
      dr_t = 0
      cr_t = 0
      dr_t += @ledgers.where(sfcat_id: uuid).where(division: 1).where('created_at >= ? AND created_at <= ?', start_date, end_date).sum(:amount)
      cr_t += @ledgers.where(sfcat_id: uuid).where(division: 2).where('created_at >= ? AND created_at <= ?', start_date, end_date).sum(:amount)
      total += default_division == 1 ? dr_t - cr_t : cr_t - dr_t
    end
    total
  end

  def cf_category_range_total(cf_category_id, default_division, start_date, end_date)
    # 与えられたCFCategoryIDに紐づく科目の、start_dateからend_dateまでの間の残高を求める
    uuids = @categories.where('cf_category_id = ?', cf_category_id).pluck(:uuid)
    total = 0

    uuids.each do |uuid|
      dr_t = 0
      cr_t = 0
      dr_t += @ledgers.where(sfcat_id: uuid).where(division: 1).where('created_at >= ? AND created_at <= ?', start_date, end_date).sum(:amount)
      cr_t += @ledgers.where(sfcat_id: uuid).where(division: 2).where('created_at >= ? AND created_at <= ?', start_date, end_date).sum(:amount)
      total += default_division == 1 ? dr_t - cr_t : cr_t - dr_t
    end
    total
  end

  def top_category_range_total(top_category_id, default_division, start_date, end_date)
    # 与えられたTopCategoryIDに紐づく科目の、start_dateからend_dateまでの間の残高を求める
    uuids = @categories.where('top_category_id = ?', top_category_id).pluck(:uuid)
    total = 0

    uuids.each do |uuid|
      dr_t = 0
      cr_t = 0
      dr_t += @ledgers.where(sfcat_id: uuid).where(division: 1).where('created_at >= ? AND created_at <= ?', start_date, end_date).sum(:amount)
      cr_t += @ledgers.where(sfcat_id: uuid).where(division: 2).where('created_at >= ? AND created_at <= ?', start_date, end_date).sum(:amount)
      total += default_division == 1 ? dr_t - cr_t : cr_t - dr_t
    end
    total
  end

  def category_balance_total_hash
    # 現金/ゆうちょ/UFJ/Suica/SBI/VISAカード/未払水道光熱費の残高算出
    result = {}
    category_data = [[1101, 1], [1104, 1], [1105, 1], [1108, 1], [1601, 1], [2106, 2], [2107, 2]]
    category_data.each do |c_data|
      result[@categories.find_by(uuid: c_data.first).name] = category_total(c_data.first, c_data.second)
    end
    result
  end

  def aggregate_hash
    # 有効現預金(VISA光)/先月末残高/先月末差/現預金合計/総資金合計/負債合計
    result = {}
    result['有効現預金(VISA光)'] = available_cash
    result['先月末残高'] = last_month_cash
    result['先月末差'] = last_month_diff
    result['現預金合計'] = total_cash
    result['総資金合計'] = super_total_cash
    result['負債合計'] = debt_total

    result
  end

  def pl_current_month_total_hash
    start_date, end_date = month_total_days

    result = {}
    result['売上高'] = sub_category_range_total(13, 2, start_date, end_date)
    result['売上原価'] = sub_category_range_total(16, 1, start_date, end_date)
    result['売上総利益'] = result['売上高'] - result['売上原価']
    result['販管費'] = sub_category_range_total(17, 1, start_date, end_date)
    result['営業利益'] = result['売上総利益'] - result['販管費']
    result['営業外収益'] = sub_category_range_total(14, 2, start_date, end_date)
    result['営業外費用'] = sub_category_range_total(18, 1, start_date, end_date)
    result['経常利益'] = result['営業利益'] + result['営業外収益'] - result['営業外費用']
    result['特別利益'] = sub_category_range_total(15, 2, start_date, end_date)
    result['特別損失'] = sub_category_range_total(19, 1, start_date, end_date)
    result['当期純利益'] = result['経常利益'] + result['特別利益'] - result['特別損失']

    @profit = result['当期純利益']
    result
  end

  def cf_current_month_total_hash
    start_date, end_date = month_total_days

    result = {}
    result['営業CF'] = cf_category_range_total(2, 2, start_date, end_date)
    result['投資CF'] = cf_category_range_total(3, 2, start_date, end_date)
    result['財務CF'] = cf_category_range_total(4, 2, start_date, end_date)
    result['FCF'] = result['営業CF'] + result['投資CF']

    result
  end

  def bs_current_month_total_hash
    start_date, end_date = month_total_days

    result = {}
    result['総資金'] = cf_category_range_total(1, 1, start_date, end_date) + category_range_total(1601, 1, start_date, end_date)
    result['当座資産'] = sub_category_range_total(1, 1, start_date, end_date)
    result['その他流動資産'] = sub_category_range_total(3, 1, start_date, end_date)
    result['流動資産合計'] = result['当座資産'] + sub_category_range_total(2, 1, start_date, end_date) + result['その他流動資産']
    result['有形固定資産'] = sub_category_range_total(4, 1, start_date, end_date)
    result['無形固定資産'] = sub_category_range_total(5, 1, start_date, end_date)
    result['投資その他の資産'] = sub_category_range_total(6, 1, start_date, end_date)
    result['固定資産合計'] = result['有形固定資産'] + result['無形固定資産'] + result['投資その他の資産']
    result['資産合計'] = top_category_range_total(1, 1, start_date, end_date)
    result['流動負債'] = sub_category_range_total(8, 2, start_date, end_date)
    result['固定負債'] = sub_category_range_total(9, 2, start_date, end_date)
    result['負債合計'] = result['流動負債'] + result['固定負債']
    result['資本/資本剰余金'] = sub_category_range_total(10, 2, start_date, end_date) + sub_category_range_total(11, 2, start_date, end_date)
    result['利益剰余金'] = sub_category_range_total(12, 2, start_date, end_date) + @profit

    result
  end

  def estimate_hash(flg)
    # 予算比：左側
    result = {}
    [4102, 5102, 5204, 5211, 5215, 5303, 5202, 5302].each do |uuid|
      result[@categories.find_by(uuid: uuid).name] = estimate_total(uuid, flg)
    end
    # 主要変動費合計
    costs = result.reject { |i| i == '給与収入' }
    total_data = []
    0.upto(4) do |i|
      total_data << (i == 3 ? '-----' : costs.values.map { |r| r[i] }.inject(:+))
    end
    result['主要変動費合計'] = total_data

    result
  end

  def estimate_total(uuid, flg)
    # 与えられたUUIDを持つ科目と予算(Estimate)を見て、科目ごとに予実計算をする
    # start_date: 期間の開始日
    # end_date: 期間の終了日
    # weekday: start_dateから今日までの平日日数
    # day_off: start_dateから今日までの休日日数
    # st_to_current_days: start_dateから今日までの経過日数
    # st_to_end_days: start_dateからend_dateまでの日数

    start_date, end_date = flg == 'month' ? month_total_days : payday_total_days
    weekday, day_off, st_to_current_days = day_category_counts(start_date)
    st_to_end_days = (end_date.to_date - start_date.to_date).to_i + 1

    if [5204, 5303, 5211, 5210, 5203, 5214].include?(uuid)
      m_est = Estimate.find_by(uuid: uuid).m_est
      progress_estimate = m_est * st_to_current_days / st_to_end_days
      cm_t = category_range_total(uuid, 1, start_date, end_date)

    elsif uuid == 5102
      m_est = Estimate.find_by(uuid: uuid).m_est
      progress_estimate = weekday * 1140 + day_off * 760
      cm_t = category_range_total(uuid, 1, start_date, end_date)

    elsif uuid == 4102
      m_est = Estimate.find_by(uuid: uuid).m_est
      progress_estimate = m_est * st_to_current_days / st_to_end_days
      cm_t = category_range_total(uuid, 2, start_date, end_date)

    elsif uuid == 5302
      m_est = Estimate.where(uuid: uuid)
      m_est = Time.zone.now.month.even? ? m_est.first.m_est : m_est.second.m_est
      progress_estimate = m_est * st_to_current_days / st_to_end_days
      cm_t = category_range_total(uuid, 1, start_date, end_date)

    else
      return [0, 0, category_range_total(uuid, 1, start_date, end_date), 0, 0 - category_range_total(uuid, 1, start_date, end_date)]
    end

    estimate_ratio = percent(cm_t, progress_estimate)
    divide = progress_estimate - cm_t
    [m_est, progress_estimate, cm_t, estimate_ratio, divide]
  end

  def balance_overview(flg)
    # 予算日：右側
    result = {}
    start_date, end_date = flg == 'month' ? month_total_days : payday_total_days

    result['収益合計'] = top_category_range_total(4, 2, start_date, end_date)

    fixed_cost_total = 0
    FIXED_COST_UUIDS.each do |uuid|
      fixed_cost_total += category_range_total(uuid, 1, start_date, end_date)
    end
    result['固定費合計(減価償却以外)'] = fixed_cost_total

    variable_cost_uuids = @categories.where(top_category_id: 5).pluck(:uuid) - FIXED_COST_UUIDS - AMORTIZATION_UUIDS
    variable_cost = 0
    variable_cost_uuids.each do |uuid|
      variable_cost += category_range_total(uuid, 1, start_date, end_date)
    end
    result['変動費合計'] = variable_cost

    result['費用合計'] = result['固定費合計(減価償却以外)'] + result['変動費合計']

    result['VISAカード'] = category_range_total(2106, 2, start_date, end_date)
    result['未払水道光熱費'] = category_range_total(2107, 2, start_date, end_date)

    result['収支'] = cf_category_range_total(1, 1, start_date, end_date) - result['VISAカード'] - result['未払水道光熱費']

    amortization_cost = AMORTIZATION_UUIDS.map { |uuid| category_range_total(uuid, 1, start_date, end_date) }.inject(:+)
    result['損益'] = result['収益合計'] - result['費用合計'] - amortization_cost

    # 未経過日数(当日含む)
    unexpired_days = (end_date.to_date - Time.current.to_date).to_i + 1
    result['1日あたり利用可能変動費'] = (result['収支'] / unexpired_days).floor

    result
  end

  # パーセント表示
  def percent(ds, dd)
    ((ds / dd.to_f)*100).round(2).to_s + '%'
  end

  # 日付計算メソッド
  def month_total_days
    # 今月の開始日と終了日を求める
    today = Time.current
    [today.beginning_of_month, today.end_of_month]
  end

  def payday_total_days
    # 15日開始日〜14日終了日の日付を求める
    if Time.current.day < 15
      lm = Time.current.ago(1.month)
      st = Time.zone.local(lm.year, lm.month, 15)
      ed = Time.zone.local(Time.current.year, Time.current.month, 14)
    else
      fm = Time.current.since(1.month)
      st = Time.zone.local(Time.current.year, Time.current.month, 15)
      ed = Time.zone.local(fm.year, fm.month, 14)
    end
    [st, ed]
  end

  def day_category_counts(start_date)
    # start_dateから今日までの平日(weekday)・休日(day_off)のカウント
    start_date = start_date.to_date
    current_date = Time.current.to_date

    st_to_current_days = (current_date - start_date).to_i + 1
    day_off_count = 0
    day_off_array = [0, 6]

    start_date.upto(current_date) do |i|
      day_off_count += 1 if day_off_array.include?(i.wday) || HolidayJp.holiday?(i).present?
    end
    weekday = st_to_current_days - day_off_count

    [weekday, day_off_count, st_to_current_days]
  end
end
