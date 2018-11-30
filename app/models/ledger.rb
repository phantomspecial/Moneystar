class Ledger < ApplicationRecord
  belongs_to :journal, optional: true

  def self.category_range_total(uuid, start_date, end_date)
    # 与えられたUUIDを持つ科目の、start_dateからend_dateの前日までの間の残高を求める
    dr_t, cr_t = category_range_raw_total(uuid, start_date, end_date)
    Category.division?(uuid) ? dr_t - cr_t : cr_t - dr_t
  end

  def self.category_range_raw_total(uuid, start_date, end_date)
    # 与えられたUUIDを持つ科目の、start_dateからend_dateの前日までの借方合計, 貸方合計を求める
    range = Ledger.where(sfcat_id: uuid).where('created_at >= ? AND created_at < ?', start_date, end_date)
    dr_t = range.where(division: Constants::DEBIT_SIDE).sum(:amount)
    cr_t = range.where(division: Constants::CREDIT_SIDE).sum(:amount)
    [dr_t, cr_t]
  end
end
