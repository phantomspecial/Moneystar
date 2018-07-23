module MonthlyFinanceHelper
  def table_row(column_name)
    row_data = @monthly_finance.pluck(column_name.to_sym).compact
    rd_leng = row_data.length
    avg = row_data.inject(:+) / rd_leng
    unless rd_leng == 13
      (13 - rd_leng).times do
        row_data << ''
      end
    end
    row_data << avg
  end
end
