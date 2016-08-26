class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= AdminUser.new # guest user (not logged in)
    initialize_roles(user)

    # Controllers which are not provided by ActiveAdmin do not get authorized.
    # ActiveAdmin controller always authorizes, therefore access to login must
    # explicitly be granted.
    can :login, :admin
  end

  def admin(user)
    can :access, :admin
    can :manage, :all
  end

  private

  #TODO: Remove old breadcrumbs and simplify this
  def initialize_roles(user)
    case user.class.to_s
      when "AdminUser"
        initialize_admin(user)
      else
        raise "Current user class could not be determined. This is a bug."
    end
  end

  def initialize_admin(user)
    send user.role, user
  end

end
