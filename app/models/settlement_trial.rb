class SettlementTrial < ApplicationRecord
  belongs_to :top_category
  belongs_to :sub_category

  def execute_trial_table
    ActiveRecord::Base.transaction do
      SettlementTrial.delete_all

      Category.all.each do |category|
        dr_t = Ledger.where(sfcat_id: category.uuid).where(division: 1).sum(:amount)
        cr_t = Ledger.where(sfcat_id: category.uuid).where(division: 2).sum(:amount)
        subtract = dr_t - cr_t
        dr_cr_val =  subtract > 0 ? 1 : 2
        blce = subtract.abs

        SettlementTrial.create(top_category_id: category.top_category_id, sub_category_id: category.sub_category_id, cf_category_id: category.cf_category_id, uuid: category.uuid, dr_total: dr_t, cr_total: cr_t, dr_cr_flg: dr_cr_val, balance: blce)
      end
    end
  end

  def profit_st_maker
    sub_categories = SubCategory.where('top_category_id > ?', 3)

    revoa = hash_maker(sub_categories[0])
    noi = hash_maker(sub_categories[1])
    ei = hash_maker(sub_categories[2])

    cos = hash_maker(sub_categories[3])
    sga = hash_maker(sub_categories[4])
    noe = hash_maker(sub_categories[5])
    el = hash_maker(sub_categories[6])

    # 出力 使用カラム数：6
    @result = []
    rev_total = addition(revoa)
    cos_total = addition(cos)
    sga_total = addition(sga)
    noi_total = addition(noi)
    noe_total = addition(noe)
    ei_total = addition(ei)
    el_total = addition(el)

    # 売上高
    pl_cat_arr_maker(sub_categories[0].cat_name, revoa, rev_total)
    # 売上原価
    pl_cat_arr_maker(sub_categories[3].cat_name, cos, cos_total)
    # 売上総利益
    gp = rev_total - cos_total
    pl_subtract_arr_maker('売上総利益', rev_total - cos_total, rev_total)
    # 販管費
    pl_cat_arr_maker(sub_categories[4].cat_name, sga, sga_total)
    # 営業利益
    op = gp - sga_total
    pl_subtract_arr_maker('営業利益', op, rev_total)
    # 営業外収益
    pl_cat_arr_maker(sub_categories[1].cat_name, noi, noi_total)
    # 営業外費用
    pl_cat_arr_maker(sub_categories[5].cat_name, noe, noe_total)
    # 経常利益
    ip = op + noi_total - noe_total
    pl_subtract_arr_maker('経常利益', ip, rev_total)
    # 特別利益
    pl_cat_arr_maker(sub_categories[2].cat_name, ei, ei_total)
    # 特別損失
    pl_cat_arr_maker(sub_categories[6].cat_name, el, el_total)
    # 当期純利益
    np = ip + ei_total - el_total
    pl_subtract_arr_maker('当期純利益', np, rev_total)

    @result
  end

  def balance_st_maker
    sub_categories = SubCategory.where('top_category_id < ?', 4)

    c_la = hash_maker(sub_categories[0])
    c_ia = hash_maker(sub_categories[1])
    c_oa = hash_maker(sub_categories[2])
    f_pe = fixed_hash_maker(sub_categories[3], 1).merge(fixed_hash_maker(sub_categories[3], 2).to_a.map{|i| [i.first, i.second * -1]}.to_h)
    f_fa = hash_maker(sub_categories[4])
    f_oa = hash_maker(sub_categories[5])
    da = hash_maker(sub_categories[6])

    cl = hash_maker(sub_categories[7])
    fl = hash_maker(sub_categories[8])

    cap = hash_maker(sub_categories[9])
    lcs = hash_maker(sub_categories[10])
    re = hash_maker(sub_categories[11])
    # 純利益計算
    cr_t1 = SettlementTrial.where(top_category_id: 4).where(dr_cr_flg: 1).sum(:balance)
    cr_t2 = SettlementTrial.where(top_category_id: 4).where(dr_cr_flg: 2).sum(:balance)
    dr_t1 = SettlementTrial.where(top_category_id: 5).where(dr_cr_flg: 1).sum(:balance)
    dr_t2 = SettlementTrial.where(top_category_id: 5).where(dr_cr_flg: 2).sum(:balance)
    profit = cr_t2 - cr_t1 - dr_t1 - dr_t2
    re['当期純利益'] = profit

    # 出力 使用カラム数:7
    @result = []
    # 流動資産
    cla_total = addition(c_la)
    cia_total = addition(c_ia)
    coa_total = addition(c_oa)
    ca_total = cla_total + cia_total + coa_total
    # 固定資産
    fpe_total = addition(f_pe)
    ffa_total = addition(f_fa)
    foa_total = addition(f_oa)
    fa_total = fpe_total + ffa_total + foa_total
    # 繰延資産
    da_total = addition(da)
    # 総資産
    asset_total = ca_total + fa_total + da_total
    # 負債
    cl_total = addition(cl)
    fl_total = addition(fl)
    debt_total = cl_total + fl_total
    # 純資産
    cap_total = addition(cap)
    lcs_total = addition(lcs)
    re_total = addition(re)
    net_ast_total = cap_total + lcs_total + re_total
    # 負債・純資産合計
    db_na_total = debt_total + net_ast_total

    # 資産の部
    # 流動資産
    @result << ['資産の部', '', '', '', '', '', '']
    bs_cat_arr_maker(sub_categories[0].cat_name, c_la, cla_total, asset_total)
    bs_cat_arr_maker(sub_categories[1].cat_name, c_ia, cia_total, asset_total)
    bs_cat_arr_maker(sub_categories[2].cat_name, c_oa, coa_total, asset_total)
    bs_subtract_arr_maker('流動資産合計', ca_total, asset_total)
    # 固定資産
    bs_cat_arr_maker(sub_categories[3].cat_name, f_pe, fpe_total, asset_total)
    bs_cat_arr_maker(sub_categories[4].cat_name, f_fa, ffa_total, asset_total)
    bs_cat_arr_maker(sub_categories[5].cat_name, f_oa, foa_total, asset_total)
    bs_subtract_arr_maker('固定資産合計', fa_total, asset_total)
    # 繰延資産
    bs_cat_arr_maker(sub_categories[6].cat_name, da, da_total, asset_total)
    bs_subtract_arr_maker('繰延資産合計', da_total, asset_total)
    bs_subtract_arr_maker('資産合計', asset_total, asset_total)

    # 負債の部
    @result << ['負債の部', '', '', '', '', '', '']
    bs_cat_arr_maker(sub_categories[7].cat_name, cl, cl_total, db_na_total)
    bs_subtract_arr_maker('流動負債合計', cl_total, db_na_total)
    bs_cat_arr_maker(sub_categories[8].cat_name, fl, fl_total, db_na_total)
    bs_subtract_arr_maker('固定負債合計', fl_total, db_na_total)
    bs_subtract_arr_maker('負債合計', debt_total, db_na_total)

    # 純資産の部
    @result << ['純資産の部', '', '', '', '', '', '']
    bs_cat_arr_maker(sub_categories[9].cat_name, cap, cap_total, db_na_total)
    bs_cat_arr_maker(sub_categories[10].cat_name, lcs, lcs_total, db_na_total)
    bs_cat_arr_maker(sub_categories[11].cat_name, re, re_total, db_na_total)
    bs_subtract_arr_maker('純資産合計', net_ast_total, db_na_total)
    bs_subtract_arr_maker('負債・純資産合計', db_na_total, db_na_total)

    @result
  end

  def cashflow_st_maker
    array = []
    categories = Category.all.order(:uuid)
    categories.each do |category|
      cfid = category.cf_category_id
      uuid = category.uuid

      dr_total = JournalDetail.where(category_id: uuid).where(division: 1).sum(:amount)
      cr_total = JournalDetail.where(category_id: uuid).where(division: 2).sum(:amount)

      subtract = cr_total - dr_total
      array << [cfid, category.name, subtract]
    end

    # 残高0科目の削除・配列からハッシュへの変更
    array.reject!{ |i| i.third == 0 }
    cashes = array.select{ |i| i.first == 1 }.map{ |i| [i.second, i.third] }.to_h
    operate = array.select{ |i| i.first == 2 }.map{ |i| [i.second, i.third] }.to_h
    invest = array.select{ |i| i.first == 3 }.map{ |i| [i.second, i.third] }.to_h
    finance = array.select{ |i| i.first == 4 }.map{ |i| [i.second, i.third] }.to_h

    # 出力 使用カラム:5
    cash_total = addition(cashes)
    ope_total = addition(operate)
    inv_total = addition(invest)
    fin_total = addition(finance)
    # キャッシュフロー
    cashflow = ope_total + inv_total + fin_total
    # 期首現金計算
    cf_cat_cash = SettlementTrial.where(cf_category_id: 1)
    current_cash_balance = cf_cat_cash.where(dr_cr_flg: 1).sum(:balance) - cf_cat_cash.where(dr_cr_flg: 2).sum(:balance)
    b_o_y = current_cash_balance - cashflow

    @result = []
    cf_cat_arr_maker('営業活動によるキャッシュフロー', operate, ope_total)
    cf_cat_arr_maker('投資活動によるキャッシュフロー', invest, inv_total)
    cf_cat_arr_maker('財務活動によるキャッシュフロー', finance, fin_total)
    cf_total_arr_maker('現金および現金同等物の増減額', cashflow)
    cf_total_arr_maker('現金および現金同等物の期首残高', b_o_y)
    cf_total_arr_maker('現金および現金同等物の期末残高', current_cash_balance)
    cf_total_arr_maker('フリーキャッシュフロー', ope_total + inv_total)

    @result
  end

  private

  def hash_maker(sub_cat)
    records = sub_cat.settlement_trials.where('balance > ?', 0).pluck(:uuid, :balance)
    hashs = Hash[*records.map {|i| [Category.find(i.first).name, i.second] }.flatten]
  end

  def fixed_hash_maker(sub_cat, flg)
    records = sub_cat.settlement_trials.where('balance > ?', 0).where(dr_cr_flg: flg).pluck(:uuid, :balance)
    hashs = Hash[*records.map {|i| [Category.find(i.first).name, i.second] }.flatten]
  end

  def addition(hashs)
    hashs.values.inject(:+) || 0
  end

  def percent(ds, dd)
    ((ds / dd.to_f)*100).round(2).to_s + '%'
  end

  def bs_cat_arr_maker(c_name, loop_obj, val_total, ast_total)
    @result << ['', c_name, '', '', '', '', '']
    loop_obj.each do |key, val|
      @result << ['', '', key, '', val, '', '']
    end
    @result << ['', '', '', c_name + '合計', '', val_total, percent(val_total, ast_total)]
  end

  def bs_subtract_arr_maker(text, val, total)
    @result << ['', '', '', text, '', val,  percent(val, total)]
  end

  def pl_cat_arr_maker(c_name, loop_obj, val_total)
    @result << [c_name, '', '', '', '', '']
    loop_obj.each do |key, val|
      @result << ['', key, '', val, '', '']
    end
    @result << ['', '', c_name + '合計', '', val_total, '']
  end

  def pl_subtract_arr_maker(text, val, total)
    @result << ['', '', text, '', val,  percent(val, total)]
  end

  def cf_cat_arr_maker(c_name, loop_obj, val_total)
    @result << [c_name, '', '', '', '']
    loop_obj.each do |key, val|
      @result << ['', key, '', val, '']
    end
    @result << ['', '', c_name + '合計', '', val_total]
  end

  def cf_total_arr_maker(c_name, total)
    @result << [c_name, '', '', '', total]
  end
end
