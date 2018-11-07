class DashboardController < ApplicationController
  def show; end

  protected

  def authorize_this!
    authorize! :access, :dashboard
  end
end
