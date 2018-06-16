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
    @categories = Category.all
    sub_categories = SubCategory.where('top_category_id > ?', 3)

    revoa = hash_maker(sub_categories[0])
    noi = hash_maker(sub_categories[1])
    ei = hash_maker(sub_categories[2])

    cos = hash_maker(sub_categories[3])
    sga = hash_maker(sub_categories[4])
    noe = hash_maker(sub_categories[5])
    el = hash_maker(sub_categories[6])

    # 出力 カラム数：6
    @result = []
    rev_total = revoa.values.inject(:+)
    cos_total = cos.values.inject(:+)
    sga_total = sga.values.inject(:+)
    noi_total = noi.values.inject(:+)
    noe_total = noe.values.inject(:+)
    ei_total = ei.values.inject(:+)
    el_total = el.values.inject(:+)

    # 売上高
    cat_arr_maker(sub_categories[0].cat_name, revoa, rev_total)
    # 売上原価
    cat_arr_maker(sub_categories[3].cat_name, cos, cos_total)
    # 売上総利益
    gp = rev_total - cos_total
    subtract_arr_maker('売上総利益', rev_total - cos_total, rev_total)
    # 販管費
    cat_arr_maker(sub_categories[4].cat_name, sga, sga_total)
    # 営業利益
    op = gp - sga_total
    subtract_arr_maker('営業利益', op, rev_total)
    # 営業外収益
    cat_arr_maker(sub_categories[1].cat_name, noi, noi_total)
    # 営業外費用
    cat_arr_maker(sub_categories[5].cat_name, noe, noe_total)
    # 経常利益
    ip = op + noi_total - noe_total
    subtract_arr_maker('経常利益', ip, rev_total)
    # 特別利益
    cat_arr_maker(sub_categories[2].cat_name, ei, ei_total)
    # 特別損失
    cat_arr_maker(sub_categories[6].cat_name, el, el_total)
    # 当期純利益
    np = ip + ei_total - el_total
    subtract_arr_maker('当期純利益', np, rev_total)

    @result
  end

  private

  def hash_maker(sub_cat)
    records = sub_cat.settlement_trials.where('balance > ?', 0).pluck(:uuid, :balance)
    hashs = Hash[*records.map {|i| [@categories.find(i.first).name, i.second] }.flatten]
  end

  def cat_arr_maker(c_name, loop_obj, val_total)
    @result << [c_name, '', '', '', '', '', '']
    total = 0
    loop_obj.each do |key, val|
      @result << ['', key, '', val, '', '', '']
    end
    @result << ['', '', c_name + '合計', '', val_total, '', '']
  end

  def subtract_arr_maker(text, val, total)
    @result << ['', '', text, '', val, ((val / total.to_f)*100).round(2).to_s + '%', '']
  end
end
