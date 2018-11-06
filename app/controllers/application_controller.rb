class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  check_authorization :unless => :devise_controller?

  before_action :authorize_this!, :unless => :devise_controller?

  protected

  def authorize_this!
    raise "Not implemented"
  end

  def after_sign_in_path_for(_resource)
    dashboard_path
  end

  def current_ability
    @current_ability ||= ::Ability.new(current_user)
  end

  def current_user
    current_admin_user
  end

  rescue_from CanCan::AccessDenied do |exception|
    Rails.logger.debug "[ApplicationController] Rescued CanCan::AccessDenied and redirecting to safety"
    redirect_to root_path, :alert => exception.message
  end
end
