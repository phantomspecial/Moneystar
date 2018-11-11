class RenameAccumCfColumnToMonthlyFinances < ActiveRecord::Migration[5.1]
  def up
    rename_column :monthly_finances, :accum_cf, :accum_fcf
  end

  def down
    rename_column :monthly_finances, :accum_fcf, :accum_cf
  end
end
