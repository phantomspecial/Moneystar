class ApplicationController < ActionController::Base
  add_flash_types :success, :info, :warning, :danger, :notice, :alert
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :tel_number, :fiscal_year])
    devise_parameter_sanitizer.permit(:account_update, keys: [:username, :tel_number, :fiscal_year])
  end
end
