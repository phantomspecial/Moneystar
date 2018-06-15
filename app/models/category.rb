class Category < ApplicationRecord
  self.primary_key = 'uuid'
  belongs_to :sub_category
  belongs_to :cf_category
  has_many :journal_details
end
