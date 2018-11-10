class CsvIncludesController < MastersController
  before_action :file_validate, only: [:forward_data, :journal_data]

  def reading; end

  def forward_data
    result = CsvProcessor.new.forward_data_import(params[:file])
    result.nil? ? redirect(1) : redirect(result)
  end

  def journal_data
    result = CsvProcessor.new.journal_csv_import(params[:file])
    result.nil? ?  redirect(2) : redirect(result)
  end

  private

  def file_validate
    return redirect(3) if params[:file].nil?
    p params[:file]
    p params[:file].content_type
    redirect(4) unless params[:file].content_type == 'text/csv'
  end

  def redirect(msg_code)
    msg = { 1 => { success: '初期データ入力処理は正常に完了しました。' },
            2 => { success: '仕訳データ入力処理は正常に完了しました。' },
            3 => { danger: 'ファイルが選択されていません。'},
            4 => { danger: '選択されたファイルは適正な形式ではありません。' },
            5 => { danger: 'SQL挿入エラーです。' },
            6 => { danger: '存在しない科目があります。科目の追加・修正を行ってください。' },
            7 => { danger: '科目がありません。科目を作成/CSV挿入処理を行ってください。' },
            9 => { danger: '内部エラーです。' }
          }

    redirect_to reading_csv_includes_path, msg[msg_code]
  end
end
