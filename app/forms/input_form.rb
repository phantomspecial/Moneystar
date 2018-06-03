class InputForm
  include ActiveModel::Model

  attr_accessor :kari_ka1, :kari_ki1, :kari_ka2, :kari_ki2, :kari_ka3, :kari_ki3, :kari_ka4, :kari_ki4, :kari_ka5, :kari_ki5,
                 :kasi_ka1, :kasi_ki1, :kasi_ka2, :kasi_ki2, :kasi_ka3, :kasi_ki3, :kasi_ka4, :kasi_ki4, :kasi_ka5, :kasi_ki5,
                 :kogaki

  def journaling
    enable_kari_arr, enable_kasi_arr = jounal_array_maker(self)

    ActiveRecord::Base.transaction do
      journal = Journal.create(kogaki: kogaki)

      enable_kari_arr.map { |r| JournalDetail.create(journal_id: journal.id, category_id: r[0], division: r[1], amount: r[2]) }
      enable_kasi_arr.map { |r| JournalDetail.create(journal_id: journal.id, category_id: r[0], division: r[1], amount: r[2]) }

      # 借方・貸方ともに1つの科目の場合
      enable_kari_arr.map { |r| Ledger.create(journal_id: journal.id, contra_id: enable_kasi_arr.first[0], division: r[1], sfcat_id: r[0], amount: r[2]) }
      enable_kasi_arr.map { |r| Ledger.create(journal_id: journal.id, contra_id: enable_kari_arr.first[0], division: r[1], sfcat_id: r[0], amount: r[2]) }
    end
  end

  private

  def jounal_array_maker(form_data)
    # 要リファクタ

    kari_data_arr = []
    kari_data_arr << [form_data.kari_ka1, 1, form_data.kari_ki1] if [form_data.kari_ka1, form_data.kari_ki1].all? {|i| i.present?}
    kari_data_arr << [form_data.kari_ka2, 1, form_data.kari_ki2] if [form_data.kari_ka2, form_data.kari_ki2].all? {|i| i.present?}
    kari_data_arr << [form_data.kari_ka3, 1, form_data.kari_ki3] if [form_data.kari_ka3, form_data.kari_ki3].all? {|i| i.present?}
    kari_data_arr << [form_data.kari_ka4, 1, form_data.kari_ki4] if [form_data.kari_ka4, form_data.kari_ki4].all? {|i| i.present?}
    kari_data_arr << [form_data.kari_ka5, 1, form_data.kari_ki5] if [form_data.kari_ka5, form_data.kari_ki5].all? {|i| i.present?}

    kasi_data_arr = []
    kasi_data_arr << [form_data.kasi_ka1, 2, form_data.kasi_ki1] if [form_data.kasi_ka1, form_data.kasi_ki1].all? {|i| i.present?}
    kasi_data_arr << [form_data.kasi_ka2, 2, form_data.kasi_ki2] if [form_data.kasi_ka2, form_data.kasi_ki2].all? {|i| i.present?}
    kasi_data_arr << [form_data.kasi_ka3, 2, form_data.kasi_ki3] if [form_data.kasi_ka3, form_data.kasi_ki3].all? {|i| i.present?}
    kasi_data_arr << [form_data.kasi_ka4, 2, form_data.kasi_ki4] if [form_data.kasi_ka4, form_data.kasi_ki4].all? {|i| i.present?}
    kasi_data_arr << [form_data.kasi_ka5, 2, form_data.kasi_ki5] if [form_data.kasi_ka5, form_data.kasi_ki5].all? {|i| i.present?}

    return kari_data_arr, kasi_data_arr
  end
end
