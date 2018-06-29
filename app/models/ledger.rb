class Ledger < ApplicationRecord
  belongs_to :journal, optional: true
end
