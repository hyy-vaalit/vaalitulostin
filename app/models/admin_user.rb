class AdminUser < ApplicationRecord
  include DeviseUserBehaviour

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable,
         :lockable, :timeoutable
end
