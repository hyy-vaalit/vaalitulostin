class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  check_authorization :unless => :devise_controller?

  protected

  def current_ability
    @current_ability ||= ::Ability.new(current_user)
  end

  def current_user_login_path
    raise "#TODO: Where to redirect user?"
  end

  def current_user
    raise "#TODO: Who is the current user?"
  end

  rescue_from CanCan::AccessDenied do |exception|
    Rails.logger.debug "[ApplicationController] Rescued CanCan::AccessDenied and redirecting to safety"
    redirect_to current_user_login_path, :alert => exception.message
  end

end
