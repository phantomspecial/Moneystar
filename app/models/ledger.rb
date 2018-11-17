class Ledger < ApplicationRecord
  belongs_to :journal, optional: true

  def self.category_range_total(uuid, default_division, start_date, end_date)
    # 与えられたUUIDを持つ科目の、start_dateからend_dateの前日までの間の残高を求める
    range = Ledger.where(sfcat_id: uuid).where('created_at >= ? AND created_at < ?', start_date, end_date)
    dr_t = range.where(division: Constants::DEBIT_SIDE).sum(:amount)
    cr_t = range.where(division: Constants::CREDIT_SIDE).sum(:amount)
    default_division == Constants::DEBIT_SIDE ? dr_t - cr_t : cr_t - dr_t
  end
end
