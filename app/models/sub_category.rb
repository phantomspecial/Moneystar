class SubCategory < ApplicationRecord
  belongs_to :top_category
  has_many :categories
  has_many :settlement_trials
end
