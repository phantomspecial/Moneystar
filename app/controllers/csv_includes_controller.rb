class CsvIncludesController < MastersController
  def reading; end

  def forward_data
    CsvProcessor.new.forward_data_import(params[:file])
    redirect_to action: :reading, success: '初期データ入力処理は正常に完了いたしました。'
  end

  def journal_data
    CsvProcessor.new.journal_csv_import(params[:file])
    redirect_to action: :reading, success: '仕訳データ入力処理は正常に完了いたしました。'
  end
end
