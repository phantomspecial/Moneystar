class MonthlyFinance < ApplicationRecord
  def monthly_data(ym)
    # y年m月1日〜y年m月末日のデータを作成する
    # payday_data_makerで作成した行をアップデートする
    set_instance
    ym = ym.to_s

    year = ym.slice(0, 4).to_i
    month = ym.slice(4, 2).to_i

    # レコード取得
    record = MonthlyFinance.find_by(month: month)
    if month == 1
      last_month_record = MonthlyFinance.find_by(month: 12)
    elsif month == 4
      last_month_record = MonthlyFinance.find_by(month: 0)
    else
      last_month_record = MonthlyFinance.find_by(month: month - 1)
    end

    # 単月系
    # 営業CF/投資CF/財務CF/FCF/入金額/出金額/単純利益
    start_date = Time.zone.local(year, month, 1)
    end_date = start_date.next_month

    ocf = cf_category_range_total(2, 2, start_date, end_date) # 営業CF
    icf = cf_category_range_total(3, 2, start_date, end_date) # 投資CF
    fcf = cf_category_range_total(4, 2, start_date, end_date) # 財務CF
    free_cf = ocf + icf # FCF

    cf_range = @categories.where(cf_category_id: 1).pluck(:uuid)
    deposit = 0
    payment = 0
    cf_range.each do |uuid|
      deposit += @ledgers.where(sfcat_id: uuid).where(division: 1).where('contra_id > ?', 0).where('created_at >= ? AND created_at < ?', start_date, end_date).sum(:amount) # 入金額
      payment += @ledgers.where(sfcat_id: uuid).where(division: 2).where('contra_id > ?', 0).where('created_at >= ? AND created_at < ?', start_date, end_date).sum(:amount) # 出金額
    end

    profit = top_category_range_total(4, 2, start_date, end_date) - top_category_range_total(5, 1, start_date, end_date) # 単純利益

    # 累積系
    # 現金月末残高(VISA)/現金月末残高/累積FCF/総合計資金/総合計資金(VISA)/累積利益の計算
    if month < 4
      start_date = Time.zone.local(year - 1, 4, 1)
    else
      start_date = Time.zone.local(year, 4, 1)
    end
    end_date = Time.zone.local(year, month, 1).next_month


    cf_range = @categories.where(cf_category_id: 1).pluck(:uuid)
    dr_t = 0
    cr_t = 0
    cf_range.each do |uuid|
      dr_t += @ledgers.where(sfcat_id: uuid).where(division: 1).where('created_at >= ? AND created_at < ?', start_date, end_date).sum(:amount)
      cr_t += @ledgers.where(sfcat_id: uuid).where(division: 2).where('created_at >= ? AND created_at < ?', start_date, end_date).sum(:amount)
    end
    total_cash = dr_t - cr_t # 現金月末残高

    # VISA光の算出
    dr_t = 0
    cr_t = 0
    [2106, 2107].each do |uuid|
      dr_t += @ledgers.where(sfcat_id: uuid).where(division: 1).where('created_at >= ? AND created_at < ?', start_date, end_date).sum(:amount)
      cr_t += @ledgers.where(sfcat_id: uuid).where(division: 2).where('created_at >= ? AND created_at < ?', start_date, end_date).sum(:amount)
    end
    visa_utils = cr_t - dr_t

    lm_vmb = total_cash - visa_utils # 現金月末残高(VISA)
    accum_cf = [ocf, icf, fcf, last_month_record.accum_fcf].inject(:+) # 累積FCF
    accum_profit = profit + last_month_record.accum_profit # 累積利益

    dr_t = @ledgers.where(sfcat_id: 1601).where(division: 1).where('created_at >= ? AND created_at < ?', start_date, end_date).sum(:amount)
    cr_t = @ledgers.where(sfcat_id: 1601).where(division: 2).where('created_at >= ? AND created_at < ?', start_date, end_date).sum(:amount)
    sbi = dr_t - cr_t
    super_total_cash = total_cash + sbi
    super_total_vu = super_total_cash - visa_utils # 総合計資金/総合計資金(VISA)

    record.update(visa_m_balance: lm_vmb,
                  m_balance: total_cash,
                  free_cf: free_cf,
                  o_cf: ocf,
                  i_cf: icf,
                  f_cf: fcf,
                  accum_fcf: accum_cf,
                  deposit_cash: deposit,
                  payment_cash: payment,
                  super_total_cash: super_total_cash,
                  super_total_visa_cash: super_total_vu,
                  m_profit: profit,
                  accum_profit: accum_profit)
  end

  def payday_data(ym)
    # 14日末のデータを作成する
    set_instance
    ym = ym.to_s

    year = ym.slice(0, 4).to_i
    month = ym.slice(4, 2).to_i

    if month < 4
      start_date = Time.zone.local(Time.current.year. - 1, 4, 1)
    else
      start_date = Time.zone.local(Time.current.year, 4, 1)
    end
    end_date = Time.zone.local(year, month, 15)

    # 現預金合計の算出
    cf_range = @categories.where(cf_category_id: 1).pluck(:uuid)
    dr_t = 0
    cr_t = 0
    cf_range.each do |uuid|
      dr_t += @ledgers.where(sfcat_id: uuid).where(division: 1).where('created_at >= ? AND created_at < ?', start_date, end_date).sum(:amount)
      cr_t += @ledgers.where(sfcat_id: uuid).where(division: 2).where('created_at >= ? AND created_at < ?', start_date, end_date).sum(:amount)
    end
    cash_total = dr_t - cr_t

    # VISA光の算出
    dr_t = 0
    cr_t = 0
    [2106, 2107].each do |uuid|
      dr_t += @ledgers.where(sfcat_id: uuid).where(division: 1).where('created_at >= ? AND created_at < ?', start_date, end_date).sum(:amount)
      cr_t += @ledgers.where(sfcat_id: uuid).where(division: 2).where('created_at >= ? AND created_at < ?', start_date, end_date).sum(:amount)
    end
    visa_utils = cr_t - dr_t

    # 入金前現預金残高(VISA)
    bfp_vmb = cash_total - visa_utils

    if month == 4
      lastmonthdata = MonthlyFinance.find_by(month: 0).bfp_visa_m_balance
    else
      lastmonthdata = MonthlyFinance.find_by(month: (month - 1)).bfp_visa_m_balance
    end

    # 入金前フロー
    flow = bfp_vmb - lastmonthdata
    MonthlyFinance.where(month: month).first_or_create(month: month, bfp_visa_m_balance: bfp_vmb, bfp_flow: flow)
  end

  def initialize_data(bvmb)
    # 期首データ作成
    set_instance
    dr_t = 0
    cr_t = 0
    @categories.where(cf_category_id: 1).pluck(:uuid).each do |uuid|
      dr_t += @ledgers.where(sfcat_id: uuid).where(division: 1).where(contra_id: 0).sum(:amount)
      cr_t += @ledgers.where(sfcat_id: uuid).where(division: 2).where(contra_id: 0).sum(:amount)
    end
    mb = dr_t - cr_t # 現金月末残高

    dr_t = @ledgers.where(sfcat_id: 1601).where(division: 1).where(contra_id: 0).sum(:amount)
    cr_t = @ledgers.where(sfcat_id: 1601).where(division: 2).where(contra_id: 0).sum(:amount)
    sbi = dr_t - cr_t

    stc =  mb + sbi # 総合計資金

    dr_t = 0
    cr_t = 0
    [2106, 2107].each do |uuid|
      dr_t += @ledgers.where(sfcat_id: uuid).where(division: 1).where(contra_id: 0).sum(:amount)
      cr_t += @ledgers.where(sfcat_id: uuid).where(division: 2).where(contra_id: 0).sum(:amount)
    end
    vu = cr_t - dr_t # VISA光

    vmb = mb - vu # 現金月末残高(VISA)
    stvc = stc - vu # 総合計資金(VISA)

    MonthlyFinance.create(month: 0, visa_m_balance: vmb, bfp_visa_m_balance: bvmb, m_balance: mb, bfp_flow: 0, free_cf: 0,
                          o_cf: 0, i_cf: 0, f_cf: 0, accum_fcf: 0, deposit_cash: 0, payment_cash: 0 ,
                          super_total_cash: stc, super_total_visa_cash: stvc, m_profit: 0, accum_profit: 0)
  end

  private

  def set_instance
    @categories = Category.all
    @ledgers = Ledger.all
  end

  def cf_category_range_total(cf_category_id, default_division, start_date, end_date)
    # 与えられたCFCategoryIDに紐づく科目の、start_dateからend_dateまでの間の残高を求める
    uuids = @categories.where('cf_category_id = ?', cf_category_id).pluck(:uuid)
    total = 0

    uuids.each do |uuid|
      dr_t = 0
      cr_t = 0
      dr_t += @ledgers.where(sfcat_id: uuid).where(division: 1).where('contra_id > ?', 0).where('created_at >= ? AND created_at < ?', start_date, end_date).sum(:amount)
      cr_t += @ledgers.where(sfcat_id: uuid).where(division: 2).where('contra_id > ?', 0).where('created_at >= ? AND created_at < ?', start_date, end_date).sum(:amount)
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
end
