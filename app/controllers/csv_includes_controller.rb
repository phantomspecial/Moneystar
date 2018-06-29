class CsvIncludesController < MastersController
  def reading; end

  def forward_data
    CsvProcessor.new.forward_data_import(params[:file])
    redirect_to action: :reading
  end
end
