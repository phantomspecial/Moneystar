class LedgersController < MastersController
  def index
    @ledgers = Ledger.all
    @categories = Category.all
  end
end
