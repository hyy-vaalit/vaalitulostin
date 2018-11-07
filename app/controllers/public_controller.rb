class PublicController < ApplicationController
  skip_authorization_check

  def index; end

  def authorize_this!
    authorize! :access, :public
  end
end
