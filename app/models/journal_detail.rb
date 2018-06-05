class JournalDetail < ApplicationRecord
  belongs_to :journal
  belongs_to :category
end
