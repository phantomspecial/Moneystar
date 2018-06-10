class InputForm
  include ActiveModel::Model

  attr_accessor :kari_ka1, :kari_ki1, :kari_ka2, :kari_ki2, :kari_ka3, :kari_ki3, :kari_ka4, :kari_ki4, :kari_ka5, :kari_ki5,
                 :kasi_ka1, :kasi_ki1, :kasi_ka2, :kasi_ki2, :kasi_ka3, :kasi_ki3, :kasi_ka4, :kasi_ki4, :kasi_ka5, :kasi_ki5,
                 :kogaki

  PERMIT_CAT_UUIDS = Category.pluck(:uuid).push('').map(&:to_s).freeze
  AMOUNT_REGEX = /\A\d+\z/
  FIRST_AMOUNT_PATTERN = [*1..9].map(&:to_s).freeze

  # validates
  validate :parameter_chk
  validates :kogaki, presence: true
  validate :amt_zero_chk
  validate :all_blank_chk
  validate :oneside_chk
  validate :duplicate_cat_chk
  validate :dr_cr_total_chk

  def journaling
    ins_kari_ar, ins_kasi_ar = journal_array_maker

    ActiveRecord::Base.transaction do
      journal = Journal.create(kogaki: kogaki)

      ins_kari_ar.map { |r| JournalDetail.create(journal_id: journal.id, category_id: r[0], division: r[1], amount: r[2]) }
      ins_kasi_ar.map { |r| JournalDetail.create(journal_id: journal.id, category_id: r[0], division: r[1], amount: r[2]) }

      ins_kari_ar.map { |r| Ledger.create(journal_id: journal.id, contra_id: ins_kasi_ar.length > 1 ? 9999 : ins_kasi_ar.first[0], division: r[1], sfcat_id: r[0], amount: r[2]) }
      ins_kasi_ar.map { |r| Ledger.create(journal_id: journal.id, contra_id: ins_kari_ar.length > 1 ? 9999 : ins_kari_ar.first[0], division: r[1], sfcat_id: r[0], amount: r[2]) }
    end
  end

  private

  def journal_array_maker
    kari_data_arr = []
    kasi_data_arr = []
    0.upto(4) do |i|
      kari_data_arr << [@kari_ka_arr[i], 1, @kari_ki_arr[i]] if [@kari_ka_arr[i], 1, @kari_ki_arr[i]].all? {|n| n.present?}
      kasi_data_arr << [@kasi_ka_arr[i], 1, @kasi_ki_arr[i]] if [@kasi_ka_arr[i], 1, @kasi_ki_arr[i]].all? {|n| n.present?}
    end
    return kari_data_arr, kasi_data_arr
  end

  def input_arr_maker
    @kari_ka_arr = [kari_ka1, kari_ka2, kari_ka3, kari_ka4, kari_ka5]
    @kari_ki_arr = [kari_ki1, kari_ki2, kari_ki3, kari_ki4, kari_ki5].map{|i| i.delete('^0-9')}
    @kasi_ka_arr = [kasi_ka1, kasi_ka2, kasi_ka3, kasi_ka4, kasi_ka5]
    @kasi_ki_arr = [kasi_ki1, kasi_ki2, kasi_ki3, kasi_ki4, kasi_ki5].map{|i| i.delete('^0-9')}
  end

  # validate関連メソッド

  def parameter_chk
    # 科目名
    errors.add(:category, 'に不正な文字があります。') if ([kari_ka1, kari_ka2, kari_ka3, kari_ka4, kari_ka5, kasi_ka1, kasi_ka2, kasi_ka3, kasi_ka4, kasi_ka5] - PERMIT_CAT_UUIDS).present?

    # 金額
    amt_arr = [kari_ki1, kari_ki2, kari_ki3, kari_ki4, kari_ki5, kasi_ki1, kasi_ki2, kasi_ki3, kasi_ki4, kasi_ki5].reject(&:blank?).map { |i| i.delete(',') }
    errors.add(:amount, 'に不正な文字があります。') unless amt_arr.all? {|i| AMOUNT_REGEX === i}
  end

  def amt_zero_chk
    input_arr_maker
    errors.add(:amount, 'に0があります。') if (@kari_ki_arr + @kasi_ki_arr).reject(&:blank?).map(&:to_i).include?(0)
  end

  def all_blank_chk
    errors.add(:input, '科目、金額を入力してください。') if (@kari_ka_arr + @kari_ki_arr + @kasi_ki_arr + @kasi_ki_arr).reject(&:blank?).blank?
  end

  def oneside_chk
    oneside_arr = []
    0.upto(4) do |i|
      # 科目と金額が両方存在する or 両方存在しないときにTrue, どちらか一方のみ存在するときにFalseを返す
      oneside_arr << !(@kari_ka_arr[i].present? ^ @kari_ki_arr[i].present?)
      oneside_arr << !(@kasi_ka_arr[i].present? ^ @kasi_ki_arr[i].present?)
    end
    errors.add(:input, '科目・金額どちらかのみに記載がある列があります。') if oneside_arr.include?(false)
  end

  def duplicate_cat_chk
    cat_arr = (@kari_ka_arr + @kasi_ka_arr).reject(&:blank?)
    uniq_cat_arr = cat_arr.uniq
    errors.add(:input, '科目に重複があります。') if cat_arr != uniq_cat_arr
  end

  def dr_cr_total_chk
    errors.add(:input, '借方・貸方合計金額に差があります。') if @kari_ki_arr.map(&:to_i).inject(:+) != @kasi_ki_arr.map(&:to_i).inject(:+)
  end
end
