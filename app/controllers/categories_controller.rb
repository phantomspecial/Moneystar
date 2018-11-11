class CategoriesController < MastersController
  def index
    @categories = Category.includes(:sub_category).includes(:cf_category).order(:uuid)
  end

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(category_params)
    return render :new unless @category.valid?

    @category.save!
    redirect_to action: :index
  end

  def edit
    @category = Category.find(params[:id])
  end

  def update
    @category = Category.find(params[:id])
    @category.name = category_params[:name]
    return render :edit unless @category.valid?

    @category.update!(name: category_params[:name])
    redirect_to action: :index
  end

  private

  def category_params
    params.require(:category).permit(:top_category_id, :sub_category_id, :cf_category_id, :uuid, :name)
  end
end
