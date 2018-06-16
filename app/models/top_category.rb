class TopCategory < ApplicationRecord
  has_many :sub_categories
  has_many :settlement_trials
end
