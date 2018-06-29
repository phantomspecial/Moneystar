require 'csv'

class CsvProcessor
  TOP_CAT = { 資産: 1, 負債: 2, 純資産: 3, 収益: 4, 費用: 5}.freeze
  SUB_CAT = {当座資産: 1, 棚卸資産: 2, その他流動資産: 3, 有形固定資産: 4, 無形固定資産: 5, 投資その他の資産: 6, 繰延資産: 7,
              流動負債: 8, 固定負債: 9, 資本金: 10, 資本剰余金: 11, 利益剰余金: 12,
              売上高: 13, 営業外収益: 14, 特別利益: 15, 売上原価: 16, 販売費および一般管理費: 17, 営業外費用: 18, 特別損失: 19}.freeze
  CF_CAT = { 現預金: 1, 営業: 2, 投資: 3, 財務: 4 }.freeze

  def forward_data_import(file)
    file_data = []
    CSV.foreach(file.path, headers: true) do |r|
      file_data << r.map { |i| i.second } if r[2].present? && r[3].present?
    end

    file_data.each do |r|
      r[0] = TOP_CAT[r[0].to_sym]
      r[1] = SUB_CAT[r[1].to_sym]
      r[3] = CF_CAT[r[3].to_sym]
      r[4] = r[4].to_i
      r[5] = r[5].to_i
    end

    # Validations
    return if (file_data.map{|i| i[0]}.uniq - TOP_CAT.values).present?

    return if (file_data.map{|i| i[1]}.uniq - SUB_CAT.values).present?

    categories = file_data.map{|i| i[2]}
    return unless categories.size == categories.uniq.size

    return if (file_data.map{|i| i[3]}.uniq - CF_CAT.values).present?

    dr_total = file_data.select{|i| i[4] == 1}.map{|i| i[5]}.inject(:+)
    cr_total = file_data.select{|i| i[4] == 2}.map{|i| i[5]}.inject(:+)
    return unless dr_total == cr_total

    # Category/Ledgerテーブル作成
    idx_arr = []
    file_data.map{|i| i[0..1]}.uniq.each do |idx_data|
      case idx_data.first
        when 1
          idx_arr << (idx_data << 0)
        when 2
          idx_arr << (idx_data << 7)
        when 3
          idx_arr << (idx_data << 9)
        when 4
          idx_arr << (idx_data << 12)
        when 5
          idx_arr << (idx_data << 15)
      end
    end

    new_cat_arr = []
    idx_arr.each do |cd|
      r_data = file_data.select{|i| i.first == cd.first && i.second == cd.second}
      r_data.each.with_index(1) do |r, idx|
        r << [r[0], r[1] - cd.third, format('%02d',idx)].join
      end
      new_cat_arr += r_data
    end

    ActiveRecord::Base.transaction do
      SettlementTrial.delete_all
      Ledger.delete_all
      JournalDetail.delete_all
      Journal.delete_all
      Category.delete_all

      new_cat_arr.each do |record|
        Category.create(top_category_id: record[0], sub_category_id: record[1], cf_category_id: record[3], uuid: record[6].to_i, name: record[2])
      end

      ledger_data = new_cat_arr.select{|i| i[0] <= 3 && i[5] != 0}
      ledger_data.each do |record|
        Ledger.create(journal_id: 0, contra_id: 0, division: record[4], sfcat_id: record[6].to_i, amount: record[5])
      end
    end
  end
end
