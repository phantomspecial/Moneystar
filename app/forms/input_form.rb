class InputForm
  include ActiveModel::Model

  attr_accessor :kari_ka1, :kari_ki1, :kari_ka2, :kari_ki2, :kari_ka3, :kari_ki3, :kari_ka4, :kari_ki4, :kari_ka5, :kari_ki5,
                 :kasi_ka1, :kasi_ki1, :kasi_ka2, :kasi_ki2, :kasi_ka3, :kasi_ki3, :kasi_ka4, :kasi_ki4, :kasi_ka5, :kasi_ki5,
                 :kogaki

  # validates


  def journaling
    ins_kari_ar, ins_kasi_ar = jounal_array_maker

    # to_iの処理




    # ActiveRecord::Base.transaction do
    #   journal = Journal.create(kogaki: kogaki)

    #   ins_kari_ar.map { |r| JournalDetail.create(journal_id: journal.id, category_id: r[0], division: r[1], amount: r[2]) }
    #   ins_kasi_ar.map { |r| JournalDetail.create(journal_id: journal.id, category_id: r[0], division: r[1], amount: r[2]) }

    #   ins_kari_ar.map { |r| Ledger.create(journal_id: journal.id, contra_id: ins_kasi_ar.length > 1 ? 9999 : ins_kasi_ar.first[0], division: r[1], sfcat_id: r[0], amount: r[2]) }
    #   ins_kasi_ar.map { |r| Ledger.create(journal_id: journal.id, contra_id: ins_kari_ar.length > 1 ? 9999 : ins_kari_ar.first[0], division: r[1], sfcat_id: r[0], amount: r[2]) }
    # end
  end

  private

  def jounal_array_maker
    # 要リファクタ
    kari_data_arr = []
    kari_data_arr << [self.kari_ka1, 1, self.kari_ki1] if [self.kari_ka1, self.kari_ki1].all? {|i| i.present?}
    kari_data_arr << [self.kari_ka2, 1, self.kari_ki2] if [self.kari_ka2, self.kari_ki2].all? {|i| i.present?}
    kari_data_arr << [self.kari_ka3, 1, self.kari_ki3] if [self.kari_ka3, self.kari_ki3].all? {|i| i.present?}
    kari_data_arr << [self.kari_ka4, 1, self.kari_ki4] if [self.kari_ka4, self.kari_ki4].all? {|i| i.present?}
    kari_data_arr << [self.kari_ka5, 1, self.kari_ki5] if [self.kari_ka5, self.kari_ki5].all? {|i| i.present?}

    kasi_data_arr = []
    kasi_data_arr << [self.kasi_ka1, 2, self.kasi_ki1] if [self.kasi_ka1, self.kasi_ki1].all? {|i| i.present?}
    kasi_data_arr << [self.kasi_ka2, 2, self.kasi_ki2] if [self.kasi_ka2, self.kasi_ki2].all? {|i| i.present?}
    kasi_data_arr << [self.kasi_ka3, 2, self.kasi_ki3] if [self.kasi_ka3, self.kasi_ki3].all? {|i| i.present?}
    kasi_data_arr << [self.kasi_ka4, 2, self.kasi_ki4] if [self.kasi_ka4, self.kasi_ki4].all? {|i| i.present?}
    kasi_data_arr << [self.kasi_ka5, 2, self.kasi_ki5] if [self.kasi_ka5, self.kasi_ki5].all? {|i| i.present?}

    return kari_data_arr, kasi_data_arr
  end
end
