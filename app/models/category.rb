class Category < ApplicationRecord
  self.primary_key = 'uuid'

  has_many :journal_details
end
