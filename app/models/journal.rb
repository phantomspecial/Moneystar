class Journal < ApplicationRecord
  has_many :journal_details

  HEADERS = %w(日付/ID 借方科目 貸方科目 元帳番号 借方金額 貸方金額)
end
