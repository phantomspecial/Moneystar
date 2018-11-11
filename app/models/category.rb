class Category < ApplicationRecord
  self.primary_key = 'uuid'
  belongs_to :sub_category
  belongs_to :cf_category
  has_many :journal_details

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

  private

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
