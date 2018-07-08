class MastersController < ApplicationController
  def index
    @categories = Category.all
    @ledgers = Ledger.all
  end
end
