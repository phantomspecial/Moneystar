class CfCategory < ApplicationRecord
  has_many :categories
  has_many :settlement_trials

  CASHS = 1
  OPERATING_CF = 2
  INVESTMENT_CF = 3
  FINANCIAL_CF = 4
end
