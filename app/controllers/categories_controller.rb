class CategoriesController < MastersController
  def index
    @categories = Category.includes(:sub_category).includes(:cf_category)
  end
end
