class CsvIncludesController < MastersController
  def reading; end

  def forward_data
    CsvProcessor.new.forward_data_import(params[:file])
    redirect_to action: :reading
  end

  def journal_data
    CsvProcessor.new.journal_csv_import(params[:file])
    redirect_to action: :reading
  end
end
