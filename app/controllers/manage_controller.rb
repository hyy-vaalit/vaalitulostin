class ManageController < ApplicationController
  protected

  def authorize_this!
    authorize! :manage, :elections
  end
end
