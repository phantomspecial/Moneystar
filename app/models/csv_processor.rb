require 'csv'

class CsvProcessor
  TOP_CAT = TopCategory.all.pluck(:cat_name, :id).to_h
  SUB_CAT = SubCategory.all.pluck(:cat_name, :id).to_h
  CF_CAT = CfCategory.all.pluck(:cat_name, :id).to_h

  def forward_data_import(file)
    file_data = []
    CSV.foreach(file.path, headers: true) do |r|
      file_data << r.map { |i| i.second } if r[2].present? && r[3].present?
    end

    file_data.each do |r|
      r[0] = TOP_CAT[r[0]]
      r[1] = SUB_CAT[r[1]]
      r[3] = CF_CAT[r[3]]
      r[5] = r[5].to_i
      r[6] = r[6].to_i
    end

    # Validations
    return 4 if (file_data.map { |i| i[0] }.uniq - TOP_CAT.values).present?

    return 4 if (file_data.map { |i| i[1] }.uniq - SUB_CAT.values).present?

    categories = file_data.map { |i| i[2] }
    return 4 unless categories.size == categories.uniq.size

    return 4 if (file_data.map { |i| i[3] }.uniq - CF_CAT.values).present?

    uuids = file_data.map { |i| i[4] }
    return 4 unless uuids.size == uuids.uniq.size

    dr_total = file_data.select { |i| i[5] == 1 }.map { |i| i[6] }.inject(:+)
    cr_total = file_data.select { |i| i[5] == 2 }.map { |i| i[6] }.inject(:+)
    return 4 unless dr_total == cr_total

    # UUID構成チェック
    flg = false
    file_data.each do |r|
      case r[0]
      when 1
        break flg = true if uuid_configuration_check?(r, 0)
      when 2
        break flg = true if uuid_configuration_check?(r, 7)
      when 3
        break flg = true if uuid_configuration_check?(r, 9)
      when 4
        break flg = true if uuid_configuration_check?(r, 12)
      when 5
        break flg = true if uuid_configuration_check?(r, 15)
      end
    end
    return 4 if flg

    # UUID順にソート
    file_data.sort_by! { |r| r[4].to_i }

    cy = Time.current.year
    um = User.first.fiscal_year

    ActiveRecord::Base.transaction do
      SettlementTrial.delete_all
      Ledger.delete_all
      JournalDetail.delete_all
      Journal.delete_all
      Category.delete_all

      file_data.each do |record|
        Category.create(top_category_id: record[0], sub_category_id: record[1], cf_category_id: record[3], uuid: record[4].to_i, name: record[2], created_at: Time.zone.local(cy, um + 1, 1))
        Ledger.create(journal_id: 0, contra_id: 0, division: record[5], sfcat_id: record[4].to_i, amount: record[6], created_at: Time.zone.local(cy, um + 1, 1))
      end
    end

    ActiveRecord::Base.transaction do
      fiscal_year_bfp_visa_m_balance = MonthlyFinance.find_by(month: um).nil? ? 0 : MonthlyFinance.find_by(month: um).bfp_visa_m_balance
      MonthlyFinance.delete_all
      MonthlyFinance.new.initialize_data(fiscal_year_bfp_visa_m_balance)
    end
    nil
  end

  def journal_csv_import(file)
    file_data = []
    CSV.foreach(file.path, headers: true) do |r|
      file_data << r.values_at
    end

    cat_hash = Category.all.pluck(:name, :uuid).to_h.freeze

    # Validation
    csv_category_array = file_data.map { |i| i[4] }.uniq
    return 4 if csv_category_array.blank?
    return 7 if cat_hash.keys.blank?
    return 6 if (csv_category_array - cat_hash.keys).present?

    file_data.each do |r|
      r[0] = r[0].to_i
      r[1] = r[1].to_i
      r[2] = r[2].to_i
      r[3] = r[3].to_i
      r[4] = cat_hash[r[4]]
      r[5] = r[5].delete(',').to_i
    end

    # Validation
    flg = false
    file_data.each do |r|
      flg = r.any? { |i| i.nil? }
    end
    return 4 if flg

    max_id = file_data.map { |i| i[0] }.max

    ActiveRecord::Base.transaction do
      1.upto (max_id) do |i|
        r_data = file_data.select { |r| r[0] == i }
        ins_kari_ar = r_data.select { |r| r[3] == 1 }.map { |d| [d[4], d[3], d[5], Time.zone.local(Time.now.year, d[1],d[2])] }
        ins_kasi_ar = r_data.select { |r| r[3] == 2 }.map { |d| [d[4], d[3], d[5], Time.zone.local(Time.now.year, d[1],d[2])] }

        journal = Journal.create(kogaki: r_data[0][6], created_at: Time.zone.local(Time.now.year, r_data[0][1], r_data[0][2]))

        ins_kari_ar.map { |r| JournalDetail.create(journal_id: journal.id, category_id: r[0], division: r[1], amount: r[2], created_at: r[3]) }
        ins_kasi_ar.map { |r| JournalDetail.create(journal_id: journal.id, category_id: r[0], division: r[1], amount: r[2], created_at: r[3]) }

        ins_kari_ar.map { |r| Ledger.create(journal_id: journal.id, contra_id: ins_kasi_ar.length > 1 ? 9999 : ins_kasi_ar.first[0], division: r[1], sfcat_id: r[0], amount: r[2], created_at: r[3]) }
        ins_kasi_ar.map { |r| Ledger.create(journal_id: journal.id, contra_id: ins_kari_ar.length > 1 ? 9999 : ins_kari_ar.first[0], division: r[1], sfcat_id: r[0], amount: r[2], created_at: r[3]) }
      end
    end
    nil
    rescue
    return 5
  end

  private

  def uuid_configuration_check?(record, minus_val)
    record[4].slice(0, 1).to_i != record[0] || record[4].slice(1, 1).to_i != (record[1] - minus_val)
  end
end
