module DeviseUserBehaviour
  extend ActiveSupport::Concern

  included do
    before_validation :generate_password, on: :create

    validates_presence_of :password, on: :create

    protected

    # Generate a password only if it was not set manually (when password_confirmation is present)
    def generate_password
      self.password = Devise.friendly_token.first(8) if password_confirmation.nil?
    end
  end
end
