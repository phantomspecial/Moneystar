class MastersController < ApplicationController
  before_action :authenticate_user!

  def index
    @categories = Category.all
    @ledgers = Ledger.all
  end
end
