class SettlementTrial < ApplicationRecord
  def execute_trial_table
    ActiveRecord::Base.transaction do
      SettlementTrial.delete_all

      Category.all.each do |category|
        dr_t = Ledger.where(sfcat_id: category.uuid).where(division: 1).sum(:amount)
        cr_t = Ledger.where(sfcat_id: category.uuid).where(division: 2).sum(:amount)
        subtract = dr_t - cr_t
        dr_cr_val =  subtract > 0 ? 1 : 2
        blce = subtract.abs

        SettlementTrial.create(uuid: category.uuid, dr_total: dr_t, cr_total: cr_t, dr_cr_flg: dr_cr_val, balance: blce)
      end
    end
  end
end
