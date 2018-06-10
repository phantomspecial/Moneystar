class JournalsController < MastersController
  before_action :set_initialize

  def index
  end

  def new
    @form = InputForm.new || session[:form]
  end

  def create
    session[:form] = @form = InputForm.new(journal_params)
    return render :new unless @form.valid?

    @form.journaling
    redirect_to root_path
  end

  private

  def journal_params
    params.require(:input_form).permit(:kari_ka1, :kari_ki1, :kari_ka2, :kari_ki2, :kari_ka3, :kari_ki3,
                                 :kari_ka4, :kari_ki4, :kari_ka5, :kari_ki5,
                                 :kasi_ka1, :kasi_ki1, :kasi_ka2, :kasi_ki2, :kasi_ka3, :kasi_ki3,
                                 :kasi_ka4, :kasi_ki4, :kasi_ka5, :kasi_ki5,
                                 :kogaki
    )
  end

  def set_initialize
    @category = Category.all
    gon.category = Category.pluck(:name)
  end
end
