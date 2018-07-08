module MastersHelper
  FIXED_COST_UUIDS = [5203, 5205, 5210, 5214, 5302]

  def cat_total(uuid, default_division)
    dr_t = @ledgers.where(sfcat_id: uuid).where(division: 1).sum(:amount)
    cr_t = @ledgers.where(sfcat_id: uuid).where(division: 2).sum(:amount)
    default_division == 1 ? dr_t - cr_t : cr_t - dr_t
  end

  # 当月の合計
  def cmonth_total(column, operator, int, default_division)
    bd = Time.current.beginning_of_month
    uuids = @categories.where("#{column} #{operator} ?", int).pluck(:uuid)
    total = 0

    uuids.each do |uuid|
      dr_t = 0
      cr_t = 0
      dr_t += @ledgers.where(sfcat_id: uuid).where(division: 1).where('created_at >= ?', bd).sum(:amount)
      cr_t += @ledgers.where(sfcat_id: uuid).where(division: 2).where('created_at >= ?', bd).sum(:amount)
      total += default_division == 1 ? dr_t - cr_t : cr_t - dr_t
    end
    total
  end

  def total_cash
    cf_range = @categories.where(cf_category_id: 1).pluck(:uuid)
    dr_t = 0
    cr_t = 0
    cf_range.each do |uuid|
      dr_t += @ledgers.where(sfcat_id: uuid).where(division: 1).sum(:amount)
      cr_t += @ledgers.where(sfcat_id: uuid).where(division: 2).sum(:amount)
    end
    dr_t - cr_t
  end

  def available_cash
    tc = total_cash
    visa = cat_total(2106, 2)
    unpay_utils = cat_total(2107, 2)
    tc - visa - unpay_utils
  end

  def last_month_data
    lm = Time.current.ago(1.month).end_of_month
    cf_range = @categories.where(cf_category_id: 1).pluck(:uuid)
    dr_t = 0
    cr_t = 0
    cf_range.each do |uuid|
      dr_t += @ledgers.where(sfcat_id: uuid).where(division: 1).where('created_at <= ?', lm).sum(:amount)
      cr_t += @ledgers.where(sfcat_id: uuid).where(division: 2).where('created_at <= ?', lm).sum(:amount)
    end
    dr_t - cr_t
  end

  def lst_diff
    available_cash - last_month_data
  end

  def super_total_cash
    sbi = @ledgers.where(sfcat_id: 1601).where(division: 1).sum(:amount) - @ledgers.where(sfcat_id: 1601).where(division: 2).sum(:amount)
    total_cash + sbi
  end

  def debt_total
    debt_range = @categories.where(top_category_id: 2).pluck(:uuid)
    dr_t = 0
    cr_t = 0
    debt_range.each do |uuid|
      dr_t += @ledgers.where(sfcat_id: uuid).where(division: 1).sum(:amount)
      cr_t += @ledgers.where(sfcat_id: uuid).where(division: 2).sum(:amount)
    end
    cr_t - dr_t
  end

  def cmonth_fixed_cost
    total = 0
    FIXED_COST_UUIDS.each do |uuid|
      total += cmonth_total('uuid', '=', uuid, 1)
    end
    total
  end

  def available_vc
    cmonth_total('uuid', '=', 4102, 2) - cmonth_fixed_cost
  end

  def variable_cost_total
    total = 0
    variable_cost_uuids = @categories.where(top_category_id: 5).pluck(:uuid) - FIXED_COST_UUIDS - [5208, 5209]
    variable_cost_uuids.each do |uuid|
      total += cmonth_total('uuid', '=', uuid, 1)
    end
    total
  end



  def pl_cm_total_hash
    result = {}
    result['売上高'] = cmonth_total('sub_category_id', '=', 13, 2)
    result['売上原価'] = cmonth_total('sub_category_id', '=', 16, 1)
    result['売上総利益'] = result['売上高'] - result['売上原価']
    result['販管費'] = cmonth_total('sub_category_id', '=', 17, 1)
    result['営業利益'] = result['売上総利益'] - result['販管費']
    result['営業外収益'] = cmonth_total('sub_category_id', '=', 14, 2)
    result['営業外費用'] = cmonth_total('sub_category_id', '=', 18, 1)
    result['経常利益'] = result['営業利益'] + result['営業外収益'] - result['営業外費用']
    result['特別利益'] = cmonth_total('sub_category_id', '=', 15, 2)
    result['特別損失'] = cmonth_total('sub_category_id', '=', 19, 1)
    result['当期純利益'] = result['経常利益'] + result['特別利益'] - result['特別損失']

    result
  end

  # def cf_ago_total_arr
  #   result = []
  #   result << cf_lm_ground_total(2)
  #   result << cf_lm_ground_total(3)
  #   result << cf_lm_ground_total(4)
  #   result << result[0] + result[1]

  #   result
  # end

  def cf_cm_total_hash
    result = {}
    result['営業CF'] = cmonth_total('cf_category_id', '=', 2, 2)
    result['投資CF'] = cmonth_total('cf_category_id', '=', 3, 2)
    result['財務CF'] = cmonth_total('cf_category_id', '=', 4, 2)
    result['FCF'] = result['営業CF'] - result['投資CF']

    result
  end

  def bs_cm_data_hash
    result = {}
    result['総資金'] = cmonth_total('cf_category_id', '=', 1, 1) + cmonth_total('uuid', '=', 1601, 1)
    result['当座資産'] = cmonth_total('sub_category_id', '=', 1, 1)
    result['その他流動資産'] = cmonth_total('sub_category_id', '=', 3, 1)
    result['流動資産合計'] = result['当座資産'] + cmonth_total('sub_category_id', '=', 2, 1) + result['その他流動資産']
    result['有形固定資産'] = cmonth_total('sub_category_id', '=', 4, 1)
    result['無形固定資産'] = cmonth_total('sub_category_id', '=', 5, 1)
    result['投資その他の資産'] = cmonth_total('sub_category_id', '=', 6, 1)
    result['固定資産合計'] = result['有形固定資産'] + result['無形固定資産'] + result['投資その他の資産']
    result['資産合計'] = cmonth_total('top_category_id', '=', 1, 1)
    result['流動負債'] = cmonth_total('sub_category_id', '=', 8, 2)
    result['固定負債'] = cmonth_total('sub_category_id', '=', 9, 2)
    result['負債合計'] = result['流動負債'] + result['固定負債']
    result['資本/資本剰余金'] = cmonth_total('sub_category_id', '=', 10, 2) + cmonth_total('sub_category_id', '=', 11, 2)
    result['利益剰余金'] = cmonth_total('sub_category_id', '=', 12, 2) + pl_cm_total_hash['当期純利益']

    result
  end

  def cost_month_estimate_hash
    result = {}
    [5102, 5204, 5211, 5215, 5303, 5202, 5302].each do |uuid|
      result[@categories.find_by(uuid: uuid).name] = current_estimate_calc(uuid)
    end
    result
  end

  def current_estimate_calc(uuid)
    weekday, dayoff, days = day_category_counts
    current_day = Time.current.day

    if [5204, 5303, 5211, 5210, 5203, 5214].include?(uuid)
      m_est = Estimate.find_by(uuid: uuid).m_est
      progress_estimate = m_est * current_day / days
      cm_t = cmonth_total('uuid', '=', uuid, 1)
    elsif uuid == 5102
      m_est = Estimate.find_by(uuid: uuid).m_est

      estimate = weekday * 1140 + dayoff * 760

      progress_estimate = estimate
      cm_t = cmonth_total('uuid', '=', 5102, 1)
    elsif uuid == 4102
      m_est = Estimate.find_by(uuid: uuid).m_est
      progress_estimate = m_est * current_day / days
      cm_t = cmonth_total('uuid', '=', uuid, 2)
    else
      return [0, 0, cmonth_total('uuid', '=', uuid, 1), 0, 0]
    end

    estimate_ratio = percent(cm_t, progress_estimate)
    divide = progress_estimate - cm_t
    [m_est, progress_estimate, cm_t, estimate_ratio, divide]
  end

  def balance_current_month_hash
    result = {}
    result['給与収益'] = balance_calc(4102)
    result['その他収益'] = [0, cmonth_total('sub_category_id', '=', 4, 2) - result['給与収益'][1], 0]
    result['固定費合計(減価除く)'] = [0, cmonth_fixed_cost, 0]
    result['利用可能変動費'] = [0, result['給与収益'][1] + result['その他収益'][1] - result['固定費合計(減価除く)'][1] , 0]
    result['変動費合計'] = [0, variable_cost_total, 0]
    result['費用合計'] = [0 ,result['固定費合計(減価除く)'][1] + result['変動費合計'][1], 0]
    result['資産支出'] = []
    result['負債支出'] = []
    result['差引'] = []

    result
  end

  def balance_calc(uuid)
    days = current_month_count_of_days
    current_day = Time.current.day

    if uuid == 4102
      m_est = Estimate.find_by(uuid: uuid).m_est
      cm_t = cmonth_total('uuid', '=', uuid, 2)
    end

    divide = cm_t - m_est

    [m_est, cm_t, divide]
  end


  # 15日系メソッド
  # 集計範囲 15日〜翌月14日
  def payday_total(uuid, default_division)
    st, ed = payday_total_days

    range = @ledgers.where(sfcat_id: uuid).where('created_at >= ? AND created_at <= ?', st, ed)

    dr_t = range.where(division: 1).sum(:amount)
    cr_t = range.where(division: 2).sum(:amount)

    default_division == 1 ? dr_t - cr_t : cr_t - dr_t
  end

  def payday_estimate_data_hash
    result = {}
    [5102, 5204, 5211, 5215, 5303, 5202, 5302].each do |uuid|
      result[@categories.find_by(uuid: uuid).name] = payday_estimate_calc(uuid)
    end
    result
  end

  def payday_balance_data_hash
    result = {}
    result['給与収益'] = payday_balance_calc(4102)
    result['その他収益'] = [0, 0, 0]
    result['固定費合計(減価除く)'] = [0, cmonth_fixed_cost, 0]
    result['利用可能変動費'] = [0, result['給与収益'][1] + result['その他収益'][1] - result['固定費合計(減価除く)'][1] , 0]
    result['変動費合計'] = [0, variable_cost_total, 0]
    result['費用合計'] = [0 ,result['固定費合計(減価除く)'][1] + result['変動費合計'][1], 0]
    result['資産支出'] = []
    result['負債支出'] = []
    result['差引'] = []

    result
  end

  def payday_balance_calc(uuid)
    st, ed = payday_total_days
    weekday, dayoff, days = day_category_counts(st.to_date, Time.current.to_date)
    m_est = Estimate.find_by(uuid: uuid).m_est
    current_day = (Time.current.to_date - st.to_date).to_i + 1
    progress_estimate = m_est * current_day / ((ed.to_date - st.to_date).to_i + 1)

    if uuid == 4102
      cm_t = payday_total(uuid, 2)
    end

    divide = cm_t - m_est

    [m_est, cm_t, divide]
  end


  def payday_estimate_calc(uuid)
    st, ed = payday_total_days
    weekday, dayoff, days = day_category_counts(st.to_date, Time.current.to_date)

    current_day = (Time.current.to_date - st.to_date).to_i + 1

    if [5204, 5303, 5211, 5210, 5203, 5214].include?(uuid)
      m_est = Estimate.find_by(uuid: uuid).m_est
      progress_estimate = m_est * current_day / ((ed.to_date - st.to_date).to_i + 1)
      cm_t =  payday_total(uuid, 1)
    elsif uuid == 5102
      m_est = Estimate.find_by(uuid: uuid).m_est

      estimate = weekday * 1140 + dayoff * 760

      progress_estimate = estimate
      cm_t = payday_total(uuid, 1)
    elsif uuid == 4102
      m_est = Estimate.find_by(uuid: uuid).m_est
      progress_estimate = m_est * current_day / ((ed.to_date - st.to_date).to_i + 1)
      cm_t = payday_total(uuid, 2)
    else
      return [0, 0, payday_total(uuid, 1), 0, 0]
    end

    estimate_ratio = percent(cm_t, progress_estimate)
    divide = progress_estimate - cm_t
    [m_est, progress_estimate, cm_t, estimate_ratio, divide]
  end

  def payday_total_days
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




  # 共通メソッド
  def current_month_count_of_days
    Date.new(Time.zone.now.year, Time.zone.now.month, -1).day
  end

  def day_category_counts(st = nil, ed = nil)
    # 現時点の平日・休日のカウント
    if [st, ed].any? { |i| i.nil?  }
      start_date = Time.current.beginning_of_month.to_date
      end_date = Time.current.to_date
    else
      start_date = st
      end_date = ed
    end

    days = (end_date - start_date).to_i + 1
    day_off_count = 0
    day_off_array = [0, 6]

    start_date.upto(end_date) do |i|
      day_off_count += 1 if day_off_array.include?(i.wday) || HolidayJp.holiday?(i).present?
    end
    weekday = days - day_off_count

    [weekday, day_off_count, days]
  end

  def percent(ds, dd)
    ((ds / dd.to_f)*100).round(2).to_s + '%'
  end
end
