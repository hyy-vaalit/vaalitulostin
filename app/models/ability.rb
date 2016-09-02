class Ability
  include CanCan::Ability

  # Does not allow guest users
  def initialize(user)
    authorize_guest(user)
    return if user.nil?

    authorize_admin(user)
  end

  private

  def authorize_admin(user)
    raise "Expected AdminUser" unless user.class == AdminUser

    can :access, :dashboard
    can :manage, :elections
  end

  def authorize_guest(user)
    can :access, :public
  end

end
