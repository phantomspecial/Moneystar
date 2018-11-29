class Category < ApplicationRecord
  self.primary_key = 'uuid'
  belongs_to :top_category
  belongs_to :sub_category
  belongs_to :cf_category
  has_many :journal_details
  has_one :budget, foreign_key: :uuid

  validates :top_category_id, :sub_category_id, :cf_category_id, :uuid, :name, presence: true
  validates :top_category_id, inclusion: { in: TopCategory.all.pluck(:id),
            message: "は#{TopCategory.all.pluck(:cat_name)}のいずれかである必要性があります。" }
  validates :sub_category_id, inclusion: { in: SubCategory.all.pluck(:id),
            message: "は#{SubCategory.all.pluck(:cat_name)}のいずれかである必要性があります。" }
  validates :cf_category_id, inclusion: { in: CfCategory.all.pluck(:id),
            message: "は#{CfCategory.all.pluck(:cat_name)}のいずれかである必要性があります。" }
  validates :uuid, length: { is: 4, message: 'は4桁で構成する必要があります。' }
  validates :uuid, exclusion: { in: Category.all.pluck(:uuid), message: 'はすでに存在します。' }, on: :create
  validates :name, exclusion: { in: Category.all.pluck(:name), message: 'はすでに存在します。' }, on: :create
  validate :uuid_configuration_check, on: :create

  scope :non_cash, -> { where.not(cf_category_id: CfCategory::CASHS) }

  # Constants
  SBI_UUID = 1601
  VISA_UTIL_UUIDS = [2106, 2107]

  def self.default_division(uuid)
    # 与えられたUUIDの標準の残高が借方か、貸方かを判定する。
    top_id = Category.find_by(uuid: uuid).top_category_id
    if top_id == 1 || top_id == 5
      Constants::DEBIT_SIDE
    else
      Constants::CREDIT_SIDE
    end
  end

  def self.top_category_range_total(top_category_id, default_division, start_date, end_date)
    # 与えられたTopCategoryIDに紐づく科目の、start_dateからend_dateまでの間の残高を求める
    uuids = Category.where('top_category_id = ?', top_category_id).pluck(:uuid)
    total = 0

    uuids.each do |uuid|
      total += Ledger.category_range_total(uuid, default_division, start_date, end_date)
    end
    total
  end

  def self.sub_category_range_total(sub_category_id, default_division, start_date, end_date)
    # 与えられたSubCategoryIDに紐づく科目の、start_dateからend_dateまでの間の残高を求める
    uuids = Category.where('sub_category_id = ?', sub_category_id).pluck(:uuid)
    total = 0

    uuids.each do |uuid|
      total += Ledger.category_range_total(uuid, default_division, start_date, end_date)
    end
    total
  end

  def self.cf_category_range_total(cf_category_id, default_division, start_date, end_date)
    # 与えられたCFCategoryIDに紐づく科目の、start_dateからend_dateまでの間の残高を求める
    uuids = Category.where('cf_category_id = ?', cf_category_id).pluck(:uuid)
    total = 0

    uuids.each do |uuid|
      total += Ledger.category_range_total(uuid, default_division, start_date, end_date)
    end
    total
  end

  def self.total_cash(start_date, end_date)
    cf_category_range_total(CfCategory::CASHS, Constants::DEBIT_SIDE, start_date, end_date)
  end

  def self.range_cash(start_date, end_date)
    # 会計期間開始〜現在を指定：　有効現預金(VISA)
    # 特定の期間を指定：　期間収支(VISA)
    total_cash(start_date, end_date) - visa_utils(start_date, end_date)
  end

  def self.last_month_available_cash
    # 先月末残高(VISA)
    result = MonthlyFinance.find_by(month: Time.current.ago(1.month).month)&.visa_m_balance
    result.presence || 0
  end

  def self.last_month_diff(start_date, end_date)
    # 先月末差(VISA)
    total_cash(start_date, end_date) - last_month_available_cash
  end

  def self.super_total_cash(start_date, end_date)
    # 総合計資金
    total_cash(start_date, end_date) + Ledger.category_range_total(SBI_UUID, Constants::DEBIT_SIDE, start_date, end_date)
  end

  def self.range_pl(start_date, end_date)
    # 期間損益 => 収益 - 費用
    profit = top_category_range_total(4, Constants::CREDIT_SIDE, start_date, end_date)
    loss = top_category_range_total(5, Constants::CREDIT_SIDE, start_date, end_date)
    profit - loss
  end

  private

  def self.visa_utils(start_date, end_date)
    visa_util = 0
    VISA_UTIL_UUIDS.each do |uuid|
      visa_util += Ledger.category_range_total(uuid, Constants::CREDIT_SIDE, start_date, end_date)
    end
    visa_util
  end

  def uuid_configuration_check
    input_uuid_top_category_id = uuid.to_s[0]
    input_uuid_sub_category_id = uuid.to_s[1]

    case top_category_id
    when 1
      correct_sub_category_id = (sub_category_id - 0).to_s
    when 2
      correct_sub_category_id = (sub_category_id - 7).to_s
    when 3
      correct_sub_category_id = (sub_category_id - 9).to_s
    when 4
      correct_sub_category_id = (sub_category_id - 12).to_s
    when 5
      correct_sub_category_id = (sub_category_id - 15).to_s
    end

    if top_category_id.to_s != input_uuid_top_category_id || correct_sub_category_id != input_uuid_sub_category_id
        errors.add(:uuid, 'の構成に不整合があります。')
    end
  end
end
