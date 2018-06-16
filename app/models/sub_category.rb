class SubCategory < ApplicationRecord
  has_many :categories
  has_many :settlement_trials
end
