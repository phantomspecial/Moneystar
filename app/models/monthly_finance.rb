class MonthlyFinance < ApplicationRecord
  def monthly_data(ym)
    # ym月末のデータを作成する
    # payday_data_makerで作成した行をアップデートする
    set_instance
    ym = ym.to_s
    # レコード取得
    if equal_user_fiscal_year?
      record = MonthlyFinance.find_by(month: 0)
    else
      parse_month = ym.slice(4, 2).to_i
      record = MonthlyFinance.find_by(month: parse_month)
    end

    agg_arr = aggregate(ym)
    lm_vmb = total_cash - visa_utils
    record.update(visa_m_balance: lm_vmb, m_balance: total_cash, free_cf: agg_arr[3],
                  o_cf: agg_arr[0], i_cf: agg_arr[1], f_cf: agg_arr[2], accum_cf: agg_arr[4], deposit_cash: agg_arr[5], payment_cash: agg_arr[6] ,
                  super_total_cash: agg_arr[7], super_total_visa_cash: agg_arr[8], m_profit: agg_arr[9], accum_profit: agg_arr[10])
  end

  def payday_data
    # 14日末のデータを作成する
    set_instance

    bfp_vmb = total_cash - visa_utils
    if equal_user_fiscal_year?
      lastmonthdata = MonthlyFinance.find_by(month: 0).bfp_visa_m_balance
    else
      lastmonthdata = MonthlyFinance.find_by(month: (Time.current.month - 1)).bfp_visa_m_balance
    end
    flow = bfp_vmb - lastmonthdata
    MonthlyFinance.create(month: Time.current.month, bfp_visa_m_balance: bfp_vmb, bfp_flow: flow)
  end

  def initialize_data(bvmb)
    # 期首データ作成
    set_instance
    mb = total_cash
    stc = super_total_cash
    vu = visa_utils
    vmb = mb - vu
    stvc = stc - vu

    MonthlyFinance.create(month: 0, visa_m_balance: vmb, bfp_visa_m_balance: bvmb, m_balance: mb, bfp_flow: 0, free_cf: 0,
                          o_cf: 0, i_cf: 0, f_cf: 0, accum_cf: 0, deposit_cash: 0, payment_cash: 0 ,
                          super_total_cash: stc, super_total_visa_cash: stvc, m_profit: 0, accum_profit: 0)
  end

  private

  def equal_user_fiscal_year?(add = 0)
    Time.current.month == User.first.fiscal_year + add
  end

  def set_instance
    @categories = Category.all
    @ledgers = Ledger.all
  end

  def category_total(uuid, default_division)
    # その科目の単純合計
    dr_t = @ledgers.where(sfcat_id: uuid).where(division: 1).sum(:amount)
    cr_t = @ledgers.where(sfcat_id: uuid).where(division: 2).sum(:amount)
    default_division == 1 ? dr_t - cr_t : cr_t - dr_t
  end

  def cf_category_range_total(cf_category_id, default_division, start_date, end_date)
    # 与えられたCFCategoryIDに紐づく科目の、start_dateからend_dateまでの間の残高を求める
    uuids = @categories.where('cf_category_id = ?', cf_category_id).pluck(:uuid)
    total = 0

    uuids.each do |uuid|
      dr_t = 0
      cr_t = 0
      dr_t += @ledgers.where(sfcat_id: uuid).where(division: 1).where('created_at >= ? AND created_at < ?', start_date, end_date).sum(:amount)
      cr_t += @ledgers.where(sfcat_id: uuid).where(division: 2).where('created_at >= ? AND created_at < ?', start_date, end_date).sum(:amount)
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
      dr_t += @ledgers.where(sfcat_id: uuid).where(division: 1).where('created_at >= ? AND created_at < ?', start_date, end_date).sum(:amount)
      cr_t += @ledgers.where(sfcat_id: uuid).where(division: 2).where('created_at >= ? AND created_at < ?', start_date, end_date).sum(:amount)
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

  def super_total_cash
    sbi = category_total(1601, 1)
    @super_total_cash =  total_cash + sbi
  end

  def visa_utils
    category_total(2106, 2) + category_total(2107, 2)
  end

  def aggregate(ym)
    # FCF/営業CF/投資CF/財務CF/累積FCF/入金額/出金額/総合計資金/総合計資金(VISA)/単純利益/累積利益の計算

    year = ym.slice(0, 4).to_i
    month = ym.slice(4, 2).to_i

    # 比較対象
    if equal_user_fiscal_year?(2)
      last_month_record = MonthlyFinance.find_by(month: 0)
    else
      last_month_record = MonthlyFinance.find_by(month: (Time.current.month - 2))
    end

    start_date = Time.zone.local(year, month, '01')
    end_date = start_date.next_month

    ocf = cf_category_range_total(2, 2, start_date, end_date)
    icf = cf_category_range_total(3, 2, start_date, end_date)
    fcf = cf_category_range_total(4, 2, start_date, end_date)
    free_cf = ocf + icf
    accum_cf = [ocf, icf, fcf, last_month_record.accum_cf].inject(:+)

    cf_range = @categories.where(cf_category_id: 1).pluck(:uuid)
    dr_t = 0
    cr_t = 0
    cf_range.each do |uuid|
      dr_t += @ledgers.where(sfcat_id: uuid).where(division: 1).where('created_at >= ? AND created_at < ?', start_date, end_date).sum(:amount)
      cr_t += @ledgers.where(sfcat_id: uuid).where(division: 2).where('created_at >= ? AND created_at < ?', start_date, end_date).sum(:amount)
    end

    profit = top_category_range_total(4, 2, start_date, end_date) - top_category_range_total(5, 1, start_date, end_date)
    accum_profit = profit + last_month_record.accum_profit

    super_total_vu = super_total_cash - visa_utils

    [ocf, icf, fcf, free_cf, accum_cf, dr_t, cr_t, super_total_cash, super_total_vu, profit, accum_profit]
  end
end
